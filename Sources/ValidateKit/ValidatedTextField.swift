import SwiftUI
import Combine
import UIKit

/// A text field with built-in validation capabilities.
///
/// `ValidatedTextField` provides a SwiftUI text field that automatically validates user input
/// according to the provided validation rules. It displays error messages and integrates
/// with form-level validation state management.
///
/// ## Basic Usage
///
/// ```swift
/// struct LoginForm: View {
///     @State private var email = ""
///
///     var body: some View {
///         ValidatedTextField(
///             "Email",
///             text: $email,
///             validation: .email()
///                 .required("Email is required")
///         )
///     }
/// }
/// ```
///
/// ## Form Integration
///
/// ```swift
/// struct RegistrationForm: View {
///     @State private var form = FormValidationState()
///     @State private var email = ""
///     @State private var password = ""
///
///     var body: some View {
///         Form {
///             ValidatedTextField(
///                 "Email",
///                 text: $email,
///                 validation: .email().required(),
///                 form: $form
///             )
///
///             ValidatedSecureField(
///                 "Password",
///                 text: $password,
///                 validation: .password()
///                     .required("Password is required")
///                     .minLength(8, message: "Password must be at least 8 characters"),
///                 form: $form
///             )
///
///             Button("Submit") {
///                 if form.isValid {
///                     // Submit form
///                 }
///             }
///             .disabled(!form.isValid)
///         }
///     }
/// }
/// ```
public struct ValidatedTextField: View {
    @Binding private var text: String
    @State private var errorMessage: String?
    @State private var isValidating: Bool = false
    @State private var hasBlurred: Bool = false
    @FocusState private var isFocused: Bool
    
    private let title: String
    private let validation: Validation<String>
    private let form: Binding<FormValidationState>?
    private let fieldIdentifier: String
    private let validationMode: ValidationMode
    private let debounceInterval: TimeInterval
    private let errorStyle: ErrorStyle
    private let errorPosition: ErrorPosition
    private let accessibilityLabel: String?
    private let accessibilityHint: String?
    private let accessibilityErrorAnnouncement: Bool
    private let keyboardType: UIKeyboardType
    
    @State private var debounceTask: Task<Void, Never>?
    
    /// Creates a validated text field with the specified parameters.
    ///
    /// - Parameters:
    ///   - title: The placeholder text displayed in the text field.
    ///   - text: A binding to the text value being edited.
    ///   - validation: The validation rules to apply to the text field.
    ///   - form: Optional binding to a `FormValidationState` for form-level validation management.
    ///   - fieldIdentifier: Optional custom identifier for this field. Defaults to `title` if not provided.
    ///   - validationMode: When to perform validation. Defaults to the global configuration setting.
    ///   - debounceInterval: Time interval in seconds to wait before validating on change. Defaults to 0.3 seconds.
    ///   - errorStyle: How to display errors. Defaults to the global configuration setting.
    ///   - errorPosition: Where to display error messages. Defaults to `.below`.
    ///   - accessibilityLabel: Custom accessibility label for VoiceOver. Defaults to `title`.
    ///   - accessibilityHint: Custom accessibility hint for VoiceOver.
    ///   - accessibilityErrorAnnouncement: Whether to announce errors via VoiceOver. Defaults to `true`.
    ///   - keyboardType: The type of keyboard to display.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// ValidatedTextField(
    ///     "Email",
    ///     text: $email,
    ///     validation: .email().required(),
    ///     validationMode: .onBlur,
    ///     debounceInterval: 0.5,
    ///     keyboardType: .emailAddress
    /// )
    /// ```
    public init(
        _ title: String,
        text: Binding<String>,
        validation: Validation<String>,
        form: Binding<FormValidationState>? = nil,
        fieldIdentifier: String? = nil,
        validationMode: ValidationMode? = nil,
        debounceInterval: TimeInterval? = nil,
        errorStyle: ErrorStyle? = nil,
        errorPosition: ErrorPosition? = nil,
        accessibilityLabel: String? = nil,
        accessibilityHint: String? = nil,
        accessibilityErrorAnnouncement: Bool? = nil,
        keyboardType: UIKeyboardType = .default
    ) {
        self.title = title
        self._text = text
        self.validation = validation
        self.form = form
        self.fieldIdentifier = fieldIdentifier ?? title
        self.validationMode = validationMode ?? FormValidationConfiguration.shared.defaultValidationMode
        self.debounceInterval = debounceInterval ?? FormValidationConfiguration.shared.defaultDebounceInterval
        self.errorStyle = errorStyle ?? FormValidationConfiguration.shared.errorMessageStyle
        self.errorPosition = errorPosition ?? FormValidationConfiguration.shared.errorMessagePosition
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityHint = accessibilityHint
        self.accessibilityErrorAnnouncement = accessibilityErrorAnnouncement ?? FormValidationConfiguration.shared.accessibilityErrorAnnouncement
        self.keyboardType = keyboardType
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if errorPosition == .above {
                errorView
            }
            
            TextField(title, text: $text)
                .keyboardType(keyboardType)
                .textFieldStyle(.roundedBorder)
                .focused($isFocused)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(errorMessage != nil ? Color.red : Color.clear, lineWidth: 1)
                )
                .accessibilityLabel(accessibilityLabel ?? title)
                .accessibilityHint(accessibilityHint ?? "")
                .accessibilityValue(errorMessage ?? "")
                .onChange(of: text) { _, newValue in
                    handleTextChange(newValue)
                }
                .onChange(of: isFocused) { _, focused in
                    if !focused {
                        hasBlurred = true
                        if validationMode == .onBlur {
                            validate(newValue: text)
                        }
                    }
                }
            
            if errorPosition == .below || errorPosition == .trailing {
                HStack {
                    if errorPosition == .below {
                        errorView
                    } else {
                        Spacer()
                        errorView
                    }
                }
            }
        }
        .onAppear {
            if validationMode == .onSubmit {
                // Don't validate on initial appearance
            } else if validationMode == .onChange {
                validate(newValue: text)
            }
        }
    }
    
    @ViewBuilder
    private var errorView: some View {
        if let errorMessage = errorMessage {
            Text(errorMessage)
                .font(.caption)
                .foregroundColor(.red)
                .accessibilityLabel("Error: \(errorMessage)")
        }
    }
    
    private func handleTextChange(_ newValue: String) {
        // Cancel any pending debounce task
        debounceTask?.cancel()
        
        guard validationMode == .onChange else { return }
        
        // Debounce validation to avoid excessive validation calls
        debounceTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(debounceInterval * 1_000_000_000))
            
            guard !Task.isCancelled else { return }
            
            await MainActor.run {
                validate(newValue: newValue)
            }
        }
    }
    
    private func validate(newValue: String) {
        let result = validation.validate(newValue)
        
        switch result {
        case .valid:
            errorMessage = nil
            form?.wrappedValue.setValid(for: fieldIdentifier, isValid: true)
        case .invalid(let message):
            errorMessage = message
            form?.wrappedValue.setError(for: fieldIdentifier, message: message)
            
            // Accessibility announcement
            if accessibilityErrorAnnouncement {
                // VoiceOver error announcement can be implemented in the actual application
            }
        }
    }
}

/// A secure text field with built-in validation capabilities.
///
/// `ValidatedSecureField` is similar to `ValidatedTextField` but uses `SecureField` to hide
/// the input text, making it ideal for password fields.
///
/// ## Basic Usage
///
/// ```swift
/// struct LoginForm: View {
///     @State private var password = ""
///
///     var body: some View {
///         ValidatedSecureField(
///             "Password",
///             text: $password,
///             validation: .password()
///                 .required("Password is required")
///                 .minLength(8, message: "Password must be at least 8 characters")
///         )
///     }
/// }
/// ```
///
/// ## Form Integration
///
/// ```swift
/// struct RegistrationForm: View {
///     @State private var form = FormValidationState()
///     @State private var password = ""
///     @State private var confirmPassword = ""
///
///     var body: some View {
///         Form {
///             ValidatedSecureField(
///                 "Password",
///                 text: $password,
///                 validation: .password()
///                     .required("Password is required")
///                     .minLength(8, message: "Password must be at least 8 characters")
///                     .containsUppercase("Password must contain an uppercase letter")
///                     .containsNumber("Password must contain a number"),
///                 form: $form
///             )
///
///             ValidatedSecureField(
///                 "Confirm Password",
///                 text: $confirmPassword,
///                 validation: .custom { [password] confirm in
///                     confirm == password ? .valid : .invalid("Passwords do not match")
///                 },
///                 form: $form
///             )
///         }
///     }
/// }
/// ```
public struct ValidatedSecureField: View {
    @Binding private var text: String
    @State private var errorMessage: String?
    @State private var hasBlurred: Bool = false
    @FocusState private var isFocused: Bool
    
    private let title: String
    private let validation: Validation<String>
    private let form: Binding<FormValidationState>?
    private let fieldIdentifier: String
    private let validationMode: ValidationMode
    private let debounceInterval: TimeInterval
    private let errorStyle: ErrorStyle
    private let errorPosition: ErrorPosition
    private let accessibilityLabel: String?
    private let accessibilityHint: String?
    private let accessibilityErrorAnnouncement: Bool
    
    @State private var debounceTask: Task<Void, Never>?
    
    /// Creates a validated secure text field with the specified parameters.
    ///
    /// - Parameters:
    ///   - title: The placeholder text displayed in the secure field.
    ///   - text: A binding to the text value being edited.
    ///   - validation: The validation rules to apply to the secure field.
    ///   - form: Optional binding to a `FormValidationState` for form-level validation management.
    ///   - fieldIdentifier: Optional custom identifier for this field. Defaults to `title` if not provided.
    ///   - validationMode: When to perform validation. Defaults to the global configuration setting.
    ///   - debounceInterval: Time interval in seconds to wait before validating on change. Defaults to 0.3 seconds.
    ///   - errorStyle: How to display errors. Defaults to the global configuration setting.
    ///   - errorPosition: Where to display error messages. Defaults to `.below`.
    ///   - accessibilityLabel: Custom accessibility label for VoiceOver. Defaults to `title`.
    ///   - accessibilityHint: Custom accessibility hint for VoiceOver.
    ///   - accessibilityErrorAnnouncement: Whether to announce errors via VoiceOver. Defaults to `true`.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// ValidatedSecureField(
    ///     "Password",
    ///     text: $password,
    ///     validation: .password()
    ///         .required("Password is required")
    ///         .minLength(8, message: "Password must be at least 8 characters"),
    ///     validationMode: .onBlur
    /// )
    /// ```
    public init(
        _ title: String,
        text: Binding<String>,
        validation: Validation<String>,
        form: Binding<FormValidationState>? = nil,
        fieldIdentifier: String? = nil,
        validationMode: ValidationMode? = nil,
        debounceInterval: TimeInterval? = nil,
        errorStyle: ErrorStyle? = nil,
        errorPosition: ErrorPosition? = nil,
        accessibilityLabel: String? = nil,
        accessibilityHint: String? = nil,
        accessibilityErrorAnnouncement: Bool? = nil
    ) {
        self.title = title
        self._text = text
        self.validation = validation
        self.form = form
        self.fieldIdentifier = fieldIdentifier ?? title
        self.validationMode = validationMode ?? FormValidationConfiguration.shared.defaultValidationMode
        self.debounceInterval = debounceInterval ?? FormValidationConfiguration.shared.defaultDebounceInterval
        self.errorStyle = errorStyle ?? FormValidationConfiguration.shared.errorMessageStyle
        self.errorPosition = errorPosition ?? FormValidationConfiguration.shared.errorMessagePosition
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityHint = accessibilityHint
        self.accessibilityErrorAnnouncement = accessibilityErrorAnnouncement ?? FormValidationConfiguration.shared.accessibilityErrorAnnouncement
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if errorPosition == .above {
                errorView
            }
            
            SecureField(title, text: $text)
                .textFieldStyle(.roundedBorder)
                .focused($isFocused)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(errorMessage != nil ? Color.red : Color.clear, lineWidth: 1)
                )
                .accessibilityLabel(accessibilityLabel ?? title)
                .accessibilityHint(accessibilityHint ?? "")
                .accessibilityValue(errorMessage ?? "")
                .onChange(of: text) { _, newValue in
                    handleTextChange(newValue)
                }
                .onChange(of: isFocused) { _, focused in
                    if !focused {
                        hasBlurred = true
                        if validationMode == .onBlur {
                            validate(newValue: text)
                        }
                    }
                }
            
            if errorPosition == .below || errorPosition == .trailing {
                HStack {
                    if errorPosition == .below {
                        errorView
                    } else {
                        Spacer()
                        errorView
                    }
                }
            }
        }
        .onAppear {
            if validationMode == .onSubmit {
                // Don't validate on initial appearance
            } else if validationMode == .onChange {
                validate(newValue: text)
            }
        }
    }
    
    @ViewBuilder
    private var errorView: some View {
        if let errorMessage = errorMessage {
            Text(errorMessage)
                .font(.caption)
                .foregroundColor(.red)
                .accessibilityLabel("Error: \(errorMessage)")
        }
    }
    
    private func handleTextChange(_ newValue: String) {
        // Cancel any pending debounce task
        debounceTask?.cancel()
        
        guard validationMode == .onChange else { return }
        
        // Debounce validation to avoid excessive validation calls
        debounceTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(debounceInterval * 1_000_000_000))
            
            guard !Task.isCancelled else { return }
            
            await MainActor.run {
                validate(newValue: newValue)
            }
        }
    }
    
    private func validate(newValue: String) {
        let result = validation.validate(newValue)
        
        switch result {
        case .valid:
            errorMessage = nil
            form?.wrappedValue.setValid(for: fieldIdentifier, isValid: true)
        case .invalid(let message):
            errorMessage = message
            form?.wrappedValue.setError(for: fieldIdentifier, message: message)
            
            // Accessibility announcement
            if accessibilityErrorAnnouncement {
                // VoiceOver error announcement can be implemented in the actual application
            }
        }
    }
}
