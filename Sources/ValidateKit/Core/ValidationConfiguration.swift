import SwiftUI
import Observation

/// Defines when validation should be performed.
///
/// Use this enum to control the timing of validation in `ValidatedTextField` and `ValidatedSecureField`.
public enum ValidationMode {
    /// Validate on every text change (with debouncing).
    ///
    /// Validation occurs after the user stops typing for the debounce interval.
    /// This provides real-time feedback while avoiding excessive validation calls.
    case onChange
    
    /// Validate when the field loses focus (blur event).
    ///
    /// Validation occurs when the user taps outside the field or moves to another field.
    /// This is the default mode and provides a good balance between user feedback and performance.
    case onBlur
    
    /// Validate only when the form is submitted.
    ///
    /// No validation occurs during user input. Use this mode when you want to validate
    /// all fields at once when the user attempts to submit the form.
    ///
    /// Validation is triggered automatically when the form is submitted through the internal
    /// state management. Use `onValidationChange` closure to track validation results.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// struct MyForm: View {
    ///     @State private var email = ""
    ///     @State private var password = ""
    ///     @State private var isEmailValid = false
    ///     @State private var isPasswordValid = false
    ///
    ///     var body: some View {
    ///         Form {
    ///             ValidatedTextField(
    ///                 "Email",
    ///                 text: $email,
    ///                 validation: .email().required(),
    ///                 onValidationChange: { isValid, _ in
    ///                     isEmailValid = isValid
    ///                 },
    ///                 validationMode: .onSubmit
    ///             )
    ///
    ///             ValidatedSecureField(
    ///                 "Password",
    ///                 text: $password,
    ///                 validation: .required(),
    ///                 onValidationChange: { isValid, _ in
    ///                     isPasswordValid = isValid
    ///                 },
    ///                 validationMode: .onSubmit
    ///             )
    ///
    ///             Button("Submit") {
    ///                 if isEmailValid && isPasswordValid {
    ///                     // Submit form
    ///                 }
    ///             }
    ///         }
    ///     }
    /// }
    /// ```
    case onSubmit
}

/// Defines where error messages should be positioned relative to the field.
///
/// Use this enum to control the layout of error messages in `ValidatedTextField` and `ValidatedSecureField`.
public enum ErrorPosition {
    /// Display errors below the field.
    ///
    /// This is the default position and works well for most form layouts.
    case below
    
    /// Display errors above the field.
    ///
    /// Useful when fields are stacked vertically and you want errors to appear before the field.
    case above
    
    /// Display errors to the trailing side (right in LTR languages, left in RTL).
    ///
    /// Useful for horizontal form layouts where space is limited vertically.
    case trailing
}

/// Global configuration for form validation behavior.
///
/// Use static properties to customize default validation settings
/// that apply to all validated fields in your application.
///
/// ## Example Usage
///
/// ```swift
/// // Configure global defaults
/// FormValidationConfiguration.defaultValidationMode = .onBlur
/// FormValidationConfiguration.defaultDebounceInterval = 0.5
/// FormValidationConfiguration.errorMessagePosition = .below
/// ```
@MainActor
public enum FormValidationConfiguration {
    /// The default error message position.
    ///
    /// This value is used when `errorPosition` is not explicitly provided to `ValidatedTextField`
    /// or `ValidatedSecureField`. Defaults to `.below`.
    public static var errorMessagePosition: ErrorPosition = .below
    
    /// The default validation mode.
    ///
    /// This value is used when `validationMode` is not explicitly provided to `ValidatedTextField`
    /// or `ValidatedSecureField`. Defaults to `.onBlur`.
    public static var defaultValidationMode: ValidationMode = .onBlur
    
    /// The default debounce interval in seconds.
    ///
    /// This value is used when `debounceInterval` is not explicitly provided to `ValidatedTextField`
    /// or `ValidatedSecureField`. Defaults to 0.3 seconds.
    ///
    /// The debounce interval only applies when `validationMode` is `.onChange`.
    /// The value must be greater than or equal to 0. Negative values will be clamped to 0.
    public static var defaultDebounceInterval: TimeInterval = 0.3
}
