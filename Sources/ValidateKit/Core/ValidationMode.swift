import SwiftUI

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
