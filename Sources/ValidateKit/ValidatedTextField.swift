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
///             validation: ValidationRule.email()
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
///                 validation: ValidationRule.email().required(),
///                 form: $form
///             )
///
///             ValidatedSecureField(
///                 "Password",
///                 text: $password,
///                 validation: ValidationRule
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
    @FocusState private var isFocused: Bool
    
    private let title: String
    private let validation: Validation<String>
    private let form: Binding<FormValidationState>?
    private let validationMode: ValidationMode
    private let debounceInterval: TimeInterval
    private let errorPosition: ErrorPosition
    private let keyboardType: UIKeyboardType
    
    @State private var debounceTask: Task<Void, Never>?
    
    /// Creates a validated text field with the specified parameters.
    ///
    /// - Parameters:
    ///   - title: The placeholder text displayed in the text field.
    ///   - text: A binding to the text value being edited.
    ///   - validation: The validation rules to apply to the text field.
    ///   - form: Optional binding to a `FormValidationState` for form-level validation management.
    ///   - validationMode: When to perform validation. Defaults to the global configuration setting.
    ///   - debounceInterval: Time interval in seconds to wait before validating on change. Defaults to 0.3 seconds.
    ///   - errorPosition: Where to display error messages. Defaults to `.below`.
    ///   - keyboardType: The type of keyboard to display.
    ///
    /// ## Example Usage
    ///
    /// ```swift
/// ValidatedTextField(
///     "Email",
///     text: $email,
///     validation: ValidationRule.email().required(),
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
        validationMode: ValidationMode? = nil,
        debounceInterval: TimeInterval? = nil,
        errorPosition: ErrorPosition? = nil,
        keyboardType: UIKeyboardType = .default
    ) {
        self.title = title
        self._text = text
        self.validation = validation
        self.form = form
        self.validationMode = validationMode ?? FormValidationConfiguration.shared.defaultValidationMode
        self.debounceInterval = debounceInterval ?? FormValidationConfiguration.shared.defaultDebounceInterval
        self.errorPosition = errorPosition ?? FormValidationConfiguration.shared.errorMessagePosition
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
                .accessibilityLabel(title)
                .accessibilityValue(errorMessage ?? "")
                .onChange(of: text) { _, newValue in
                    handleTextChange(newValue)
                }
                .onChange(of: isFocused) { _, focused in
                    if !focused && validationMode == .onBlur {
                        validate(value: text)
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
            if validationMode == .onChange {
                validate(value: text)
            }
        }
        .onDisappear {
            debounceTask?.cancel()
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
    
    private var helper: ValidationFieldHelper {
        ValidationFieldHelper(
            title: title,
            validation: validation,
            form: form,
            validationMode: validationMode,
            debounceInterval: debounceInterval
        )
    }
    
    private func handleTextChange(_ newValue: String) {
        debounceTask = helper.handleTextChange(newValue, currentDebounceTask: debounceTask, errorMessage: $errorMessage)
    }
    
    private func validate(value: String) {
        helper.validate(value: value, errorMessage: $errorMessage)
    }
}
