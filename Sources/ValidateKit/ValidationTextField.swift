import SwiftUI
import Combine
import UIKit

/// A text field with built-in validation capabilities.
///
/// `ValidationTextField` provides a SwiftUI text field that automatically validates user input
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
///         ValidationTextField(
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
/// You can use `onValidationChange` closure to track individual field validation:
///
/// ```swift
/// struct RegistrationForm: View {
///     @State private var email = ""
///     @State private var password = ""
///     @State private var isEmailValid = false
///     @State private var isPasswordValid = false
///
///     var body: some View {
///         Form {
///             ValidationTextField(
///                 "Email",
///                 text: $email,
///                 validation: ValidationRule.email().required(),
///                 onValidationChange: { isValid, _ in
///                     isEmailValid = isValid
///                 }
///             )
///
///             ValidationSecureField(
///                 "Password",
///                 text: $password,
///                 validation: ValidationRule
///                     .required("Password is required")
///                     .minLength(8, message: "Password must be at least 8 characters"),
///                 onValidationChange: { isValid, _ in
///                     isPasswordValid = isValid
///                 }
///             )
///
///             Button("Submit") {
///                 if isEmailValid && isPasswordValid {
///                     // Submit form
///                 }
///             }
///             .disabled(!isEmailValid || !isPasswordValid)
///         }
///     }
/// }
/// ```
///
/// Or use `FormValidationState` for form-level validation management, especially with `.onSubmit` mode:
///
/// ```swift
/// struct RegistrationForm: View {
///     @State private var form = FormValidationState()
///     @State private var email = ""
///     @State private var password = ""
///
///     var body: some View {
///         Form {
///             ValidationTextField(
///                 "Email",
///                 text: $email,
///                 validation: ValidationRule.email().required(),
///                 form: form,
///                 validationMode: .onSubmit
///             )
///
///             ValidationSecureField(
///                 "Password",
///                 text: $password,
///                 validation: ValidationRule
///                     .required("Password is required")
///                     .minLength(8, message: "Password must be at least 8 characters"),
///                 form: form,
///                 validationMode: .onSubmit
///             )
///
///             Button("Submit") {
///                 if form.validateAll() {
///                     // Submit form
///                 }
///             }
///             .disabled(!form.isValid)
///         }
///     }
/// }
/// ```
public struct ValidationTextField: View {
    @Binding private var text: String
    @State private var errorMessage: String?
    @FocusState private var isFocused: Bool
    
    private let title: String
    private let fieldID: String
    private let validation: Validation<String>
    private let form: FormValidationState?
    private let onValidationChange: ((Bool, String?) -> Void)?
    private let validationMode: ValidationMode
    private let debounceInterval: TimeInterval
    private let errorPosition: ErrorPosition?
    private let keyboardType: UIKeyboardType
    
    @State private var debounceTask: Task<Void, Never>?
    
    /// Creates a validated text field with the specified parameters.
    ///
    /// - Parameters:
    ///   - title: The placeholder text displayed in the text field.
    ///   - text: A binding to the text value being edited.
    ///   - validation: The validation rules to apply to the text field.
    ///   - fieldID: Optional unique identifier for this field. Used with `FormValidationState` to identify the field when calling `error(for:)` or `isValid(for:)`. If not provided, defaults to `title`.
    ///   - form: Optional binding to a `FormValidationState` for form-level validation management. Use this for `.onSubmit` mode to call `validateAll()`.
    ///   - onValidationChange: Optional closure called when validation state changes. Receives `(isValid: Bool, errorMessage: String?)`.
    ///   - validationMode: When to perform validation. Defaults to the global configuration setting.
    ///   - debounceInterval: Time interval in seconds to wait before validating on change. Defaults to 0.3 seconds.
    ///   - errorPosition: Where to display error messages. Pass `nil` to hide error messages. Defaults to `.below` if not specified.
    ///   - keyboardType: The type of keyboard to display.
    ///
    /// ## Example Usage
    ///
    /// ```swift
/// ValidationTextField(
///     "Email",
///     text: $email,
///     validation: ValidationRule.email().required(),
///     fieldID: "email",
///     onValidationChange: { isValid, errorMessage in
///         print("Email is valid: \(isValid)")
///     },
///     validationMode: .onBlur,
///     debounceInterval: 0.5,
///     keyboardType: .emailAddress
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
        errorPosition: ErrorPosition? = nil,
        keyboardType: UIKeyboardType = .default
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
        self.keyboardType = keyboardType
    }
    
    
    public var body: some View {
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
                TextField(title, text: textBinding)
                    .keyboardType(keyboardType)
                    .autocapitalization(.none)
                    .textFieldStyle(.roundedBorder)
            },
            text: $text
        )
    }
}
