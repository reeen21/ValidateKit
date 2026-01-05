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
    /// Validation must be triggered manually. Use this mode when you need full control
    /// over when validation occurs.
    case manual
}

/// Defines how error messages should be displayed.
///
/// Use this enum to customize the visual presentation of validation errors.
public enum ErrorStyle {
    /// Default inline error display.
    ///
    /// Errors are displayed as text below, above, or beside the field based on `ErrorPosition`.
    case `default`
    
    /// Display errors in a tooltip/popover.
    ///
    /// Errors appear in a tooltip when the user hovers over or focuses on the field.
    case tooltip
    
    /// Display errors in an alert dialog.
    ///
    /// Errors appear in a modal alert dialog. Use sparingly as it interrupts user flow.
    case alert
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
/// FormValidationConfiguration.shared.accessibilityErrorAnnouncement = true
/// ```
@Observable
@MainActor
public final class FormValidationConfiguration {
    /// The shared configuration instance.
    ///
    /// Modify properties on this instance to change global validation defaults.
    public static let shared = FormValidationConfiguration()
    
    /// The default error message display style.
    ///
    /// This value is used when `errorStyle` is not explicitly provided to `ValidatedTextField`
    /// or `ValidatedSecureField`. Defaults to `.default`.
    public var errorMessageStyle: ErrorStyle = .default
    
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
    
    /// Whether to automatically announce validation errors via VoiceOver.
    ///
    /// When `true`, validation errors are automatically announced to VoiceOver users.
    /// This improves accessibility for users with visual impairments.
    ///
    /// Defaults to `true`.
    public var accessibilityErrorAnnouncement: Bool = true
    
    private init() {}
}
