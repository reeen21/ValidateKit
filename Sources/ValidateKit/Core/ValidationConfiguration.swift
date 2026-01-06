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
    case onSubmit
    
    /// Manual validation only.
    ///
    /// Validation must be triggered manually using `validateManually()` method.
    /// Use this mode when you need full control over when validation occurs.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// struct MyForm: View {
    ///     @State private var email = ""
    ///     @State private var emailField: ValidatedTextField?
    ///
    ///     var body: some View {
    ///         ValidatedTextField(
    ///             "Email",
    ///             text: $email,
    ///             validation: .email().required(),
    ///             validationMode: .manual
    ///         )
    ///         .onAppear {
    ///             // Store reference if needed
    ///         }
    ///
    ///         Button("Validate") {
    ///             // Trigger validation manually
    ///         }
    ///     }
    /// }
    /// ```
    case manual
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
/// Use `FormValidationConfiguration.shared` to customize default validation settings
/// that apply to all validated fields in your application.
///
/// ## Example Usage
///
/// ```swift
/// // Configure global defaults
/// FormValidationConfiguration.shared.defaultValidationMode = .onBlur
/// FormValidationConfiguration.shared.defaultDebounceInterval = 0.5
/// FormValidationConfiguration.shared.errorMessagePosition = .below
/// ```
@Observable
@MainActor
public final class FormValidationConfiguration {
    /// The shared configuration instance.
    ///
    /// Modify properties on this instance to change global validation defaults.
    public static let shared = FormValidationConfiguration()
    
    /// The default error message position.
    ///
    /// This value is used when `errorPosition` is not explicitly provided to `ValidatedTextField`
    /// or `ValidatedSecureField`. Defaults to `.below`.
    public var errorMessagePosition: ErrorPosition = .below
    
    /// The default validation mode.
    ///
    /// This value is used when `validationMode` is not explicitly provided to `ValidatedTextField`
    /// or `ValidatedSecureField`. Defaults to `.onBlur`.
    public var defaultValidationMode: ValidationMode = .onBlur
    
    /// The default debounce interval in seconds.
    ///
    /// This value is used when `debounceInterval` is not explicitly provided to `ValidatedTextField`
    /// or `ValidatedSecureField`. Defaults to 0.3 seconds.
    ///
    /// The debounce interval only applies when `validationMode` is `.onChange`.
    public var defaultDebounceInterval: TimeInterval = 0.3
    
    private init() {}
}
