import SwiftUI

/// A secure text field with built-in validation capabilities.
///  
/// `ValidationSecureField` is similar to `ValidationTextField` but uses `SecureField` to hide
/// the input text, making it ideal for password fields.
///  
/// ## Basic Usage
///  
/// ```swift
/// struct LoginForm: View {
///     @State private var password = ""
///  
///     var body: some View {
///         ValidationSecureField(
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
///    @State private var password = ""
///    @State private var confirmPassword = ""
///    @State private var isPasswordValid = false
///    @State private var isConfirmPasswordValid = false
///
///    var body: some View {
///        ValidationSecureField(
///           "Enter Password",
///           text: $password,
///           validation:
///                .required(message: "Password is required")
///                .minLength(8, message: "Password must be at least 8 characters")
///                .containsUppercase(message: "Password must contain an uppercase letter")
///                .containsNumber(message: "Password must contain a number"),
///            onValidationChange: { isValid, _ in
///                isPasswordValid = isValid
///            }
///        )
///
///        ValidationSecureField(
///            "Enter Confirm Password",
///            text: $confirmPassword,
///            validation: .custom { [password] confirm in
///                confirm == password ? .valid : .invalid("Passwords do not match")
///            },
///            onValidationChange: { isValid, _ in
///                isConfirmPasswordValid = isValid
///            }
///        )
///    }
///}

/// ```
public struct ValidationSecureField: View {
    @Binding private var text: String
    @State private var errorMessage: String?
    @State private var isPasswordVisible: Bool = false
    @FocusState private var isFocused: Bool
    
    private let title: String
    private let fieldID: String
    private let validation: Validation<String>
    private let form: FormValidationState?
    private let onValidationChange: ((Bool, String?) -> Void)?
    private let validationMode: ValidationMode
    private let debounceInterval: TimeInterval
    private let errorPosition: ErrorPosition?
    
    @State private var debounceTask: Task<Void, Never>?
    
    /// Creates a validated secure text field with the specified parameters.
    ///
    /// - Parameters:
    ///   - title: The placeholder text displayed in the secure field.
    ///   - text: A binding to the text value being edited.
    ///   - validation: The validation rules to apply to the secure field.
    ///   - fieldID: Optional unique identifier for this field. Used with `FormValidationState` to identify the field when calling `error(for:)` or `isValid(for:)`. If not provided, defaults to `title`.
    ///   - form: Optional binding to a `FormValidationState` for form-level validation management. Use this for `.onSubmit` mode to call `validateAll()`.
    ///   - onValidationChange: Optional closure called when validation state changes. Receives `(isValid: Bool, errorMessage: String?)`.
    ///   - validationMode: When to perform validation. Defaults to the global configuration setting.
    ///   - debounceInterval: Time interval in seconds to wait before validating on change. Defaults to 0.3 seconds.
    ///   - errorPosition: Where to display error messages. Pass `nil` to hide error messages. Defaults to `.below` if not specified.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// ValidationSecureField(
    ///     "Password",
    ///     text: $password,
    ///     validation:
    ///         .required("Password is required")
    ///         .minLength(8, message: "Password must be at least 8 characters"),
    ///     fieldID: "password",
    ///     onValidationChange: { isValid, errorMessage in
    ///         print("Password is valid: \(isValid)")
    ///     },
    ///     validationMode: .onBlur
    /// )
    /// ```
    public init(
        _ title: String,
        text: Binding<String>,
        validation: Validation<String>,
        fieldID: String? = nil,
        form: FormValidationState? = nil,
        onValidationChange: ((Bool, String?) -> Void)? = nil,
        validationMode: ValidationMode? = nil,
        debounceInterval: TimeInterval? = nil,
        errorPosition: ErrorPosition? = nil
    ) {
        self.title = title
        self.fieldID = fieldID ?? title
        self._text = text
        self.validation = validation
        self.form = form
        self.onValidationChange = onValidationChange
        self.validationMode = validationMode ?? FormValidationConfiguration.defaultValidationMode
        let defaultInterval = debounceInterval ?? FormValidationConfiguration.defaultDebounceInterval
        self.debounceInterval = max(0, defaultInterval)
        self.errorPosition = errorPosition
    }
    
    public var body: some View {
        HStack {
            ValidationFieldView(
                errorMessage: $errorMessage,
                isFocused: $isFocused,
                title: title,
                fieldID: fieldID,
                validation: validation,
                form: form,
                onValidationChange: onValidationChange,
                validationMode: validationMode,
                debounceInterval: debounceInterval,
                errorPosition: errorPosition,
                debounceTask: $debounceTask,
                content: { textBinding in
                    Group {
                        if isPasswordVisible {
                            TextField(title, text: textBinding)
                                .autocapitalization(.none)
                        } else {
                            SecureField(title, text: textBinding)
                                .autocapitalization(.none)
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
}
