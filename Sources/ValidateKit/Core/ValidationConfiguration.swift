import SwiftUI

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
/// ```
@MainActor
public enum FormValidationConfiguration {
    /// The default validation mode.
    ///
    /// This value is used when `validationMode` is not explicitly provided to `ValidationTextField`
    /// or `ValidationSecureField`. Defaults to `.onBlur`.
    public static var defaultValidationMode: ValidationMode = .onBlur
    
    /// The default debounce interval in seconds.
    ///
    /// This value is used when `debounceInterval` is not explicitly provided to `ValidationTextField`
    /// or `ValidationSecureField`. Defaults to 0.3 seconds.
    ///
    /// The debounce interval only applies when `validationMode` is `.onChange`.
    /// The value must be greater than or equal to 0. Negative values will be clamped to 0.
    public static var defaultDebounceInterval: TimeInterval = 0.3
}
