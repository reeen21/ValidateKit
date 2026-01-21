import SwiftUI

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
///             validation:
///                 .required(message: "Password is required")
///                 .minLength(8, message: "Password must be at least 8 characters")
///         )
///     }
/// }
/// ```
///  
/// ## Form Integration
///  
/// ```swift
///struct RegistrationForm: View {
///    @State private var form = FormValidationState()
///    @State private var password = ""
///    @State private var confirmPassword = ""
///
///    var body: some View {
///        ValidatedSecureField(
///           "Enter Password",
///           text: $password,
///           validation:
///                .required(message: "Password is required")
///                .minLength(8, message: "Password must be at least 8 characters")
///                .containsUppercase(message: "Password must contain an uppercase letter")
///                .containsNumber(message: "Password must contain a number"),
///            form: $form
///        )
///
///        ValidatedSecureField(
///            "Enter Confirm Password",
///            text: $confirmPassword,
///            validation: .custom { [password] confirm in
///                confirm == password ? .valid : .invalid("Passwords do not match")
///            },
///            form: $form
///        )
///    }
///}

/// ```
public struct ValidatedSecureField: View {
    @Binding private var text: String
    @State private var errorMessage: String?
    @State private var isPasswordVisible: Bool = false
    @FocusState private var isFocused: Bool
    
    private let title: String
    private let validation: Validation<String>
    private let form: Binding<FormValidationState>?
    private let validationMode: ValidationMode
    private let debounceInterval: TimeInterval
    private let errorPosition: ErrorPosition
    
    @State private var debounceTask: Task<Void, Never>?
    
    /// Creates a validated secure text field with the specified parameters.
    ///
    /// - Parameters:
    ///   - title: The placeholder text displayed in the secure field.
    ///   - text: A binding to the text value being edited.
    ///   - validation: The validation rules to apply to the secure field.
    ///   - form: Optional binding to a `FormValidationState` for form-level validation management.
    ///   - validationMode: When to perform validation. Defaults to the global configuration setting.
    ///   - debounceInterval: Time interval in seconds to wait before validating on change. Defaults to 0.3 seconds.
    ///   - errorPosition: Where to display error messages. Defaults to `.below`.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// ValidatedSecureField(
    ///     "Password",
    ///     text: $password,
    ///     validation:
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
        validationMode: ValidationMode? = nil,
        debounceInterval: TimeInterval? = nil,
        errorPosition: ErrorPosition? = nil
    ) {
        self.title = title
        self._text = text
        self.validation = validation
        self.form = form
        self.validationMode = validationMode ?? FormValidationConfiguration.shared.defaultValidationMode
        let defaultInterval = debounceInterval ?? FormValidationConfiguration.shared.defaultDebounceInterval
        self.debounceInterval = max(0, defaultInterval)
        self.errorPosition = errorPosition ?? FormValidationConfiguration.shared.errorMessagePosition
    }
    
    public var body: some View {
        HStack {
            ValidationFieldView(
                errorMessage: $errorMessage,
                isFocused: $isFocused,
                title: title,
                validation: validation,
                form: form,
                validationMode: validationMode,
                debounceInterval: debounceInterval,
                errorPosition: errorPosition,
                debounceTask: $debounceTask,
                content: { textBinding in
                    Group {
                        if isPasswordVisible {
                            TextField(title, text: textBinding)
                        } else {
                            SecureField(title, text: textBinding)
                        }
                    }
                    .textFieldStyle(.roundedBorder)
                },
                text: $text
            )
            
            Button {
                isPasswordVisible.toggle()
            } label: {
                Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(isPasswordVisible ? "Hide password" : "Show password")
        }
    }
    
    /// Validates the secure field manually.
    ///
    /// Use this method when `validationMode` is set to `.manual` or `.onSubmit`
    /// to trigger validation programmatically.
    ///
    /// - Returns: `true` if validation passed, `false` otherwise.
    public func validateManually() -> Bool {
        let helper = ValidationFieldHelper(
            title: title,
            validation: validation,
            form: form,
            validationMode: validationMode,
            debounceInterval: debounceInterval
        )
        helper.validate(value: text, errorMessage: $errorMessage)
        return errorMessage == nil
    }
}
