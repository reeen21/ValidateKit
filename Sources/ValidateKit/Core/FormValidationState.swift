import SwiftUI
import Observation

/// Manages the validation state for an entire form.
///
/// `FormValidationState` tracks validation errors and states for multiple form fields,
/// allowing you to check if the entire form is valid and manage field-level errors.
///
/// Use `@State` to create an instance in your SwiftUI view:
///
/// ```swift
/// struct MyForm: View {
///     @State private var form = FormValidationState()
///     @State private var email = ""
///
///     var body: some View {
///         ValidationTextField(
///             "Email",
///             text: $email,
///             validation: .email().required(),
///             form: $form
///         )
///
///         Button("Submit") {
///             if form.validateAll() {
///                 // Submit form
///             }
///         }
///         .disabled(!form.isValid)
///     }
/// }
/// ```
@Observable
@MainActor
public final class FormValidationState {
    public init() {}
    /// A dictionary mapping field identifiers to their error messages.
    ///
    /// Keys are field identifiers (typically the field title or a custom identifier),
    /// values are error messages displayed to the user.
    public private(set) var errors: [String: String] = [:]
    
    /// A dictionary mapping field identifiers to their validation state.
    ///
    /// Keys are field identifiers, values are `true` if the field is valid, `false` otherwise.
    public private(set) var fieldStates: [String: Bool] = [:]
    
    /// A dictionary mapping field identifiers to their validation functions.
    ///
    /// Used to trigger validation for fields with `.onSubmit` mode when the form is submitted.
    private var validationFunctions: [String: () -> Void] = [:]
    
    /// Returns `true` if all fields in the form are valid, `false` otherwise.
    ///
    /// Use this property to enable/disable submit buttons or determine if the form can be submitted.
    ///
    /// - Returns: `true` if all fields pass validation, `false` if any field has errors.
    ///
    /// ## Note
    ///
    /// If no fields have been validated yet (empty form), this property returns `true`.
    /// This allows submit buttons to be enabled initially, and validation will occur
    /// when fields are validated according to their `validationMode`.
    public var isValid: Bool {
        fieldStates.values.allSatisfy { $0 }
    }
    
    /// Sets an error message for a specific field.
    ///
    /// If `message` is `nil`, the error is cleared and the field is marked as valid.
    ///
    /// - Parameters:
    ///   - field: The identifier of the field (typically the field title or a custom identifier).
    ///   - message: The error message to display, or `nil` to clear the error.
    func setError(for field: String, message: String?) {
        if let message = message {
            errors[field] = message
            fieldStates[field] = false
        } else {
            errors.removeValue(forKey: field)
            fieldStates[field] = true
        }
    }
    
    /// Sets the validation state for a specific field.
    ///
    /// - Parameters:
    ///   - field: The identifier of the field.
    ///   - isValid: `true` if the field is valid, `false` otherwise.
    ///
    /// ## Note
    ///
    /// When `isValid` is `false`, this method only updates the field state but does not set an error message.
    /// Use `setError(for:message:)` if you need to set a specific error message.
    func setValid(for field: String, isValid: Bool) {
        if isValid {
            errors.removeValue(forKey: field)
            fieldStates[field] = true
        } else {
            // Keep existing error message if any, but mark field as invalid
            fieldStates[field] = false
        }
    }
    
    /// Clears all errors and validation states for all fields.
    public func clearErrors() {
        errors.removeAll()
        fieldStates.removeAll()
    }
    
    /// Clears the error for a specific field and marks it as valid.
    ///
    /// - Parameter fieldID: The unique identifier of the field to clear. This should match the `fieldID` parameter passed to `ValidationTextField` or `ValidationSecureField`.
    public func clearError(for fieldID: String) {
        errors.removeValue(forKey: fieldID)
        fieldStates[fieldID] = true
    }
    
    /// Returns the error message for a specific field, if any.
    ///
    /// - Parameter fieldID: The unique identifier of the field. This should match the `fieldID` parameter passed to `ValidationTextField` or `ValidationSecureField`. If `fieldID` was not provided, use the field's `title` (placeholder text).
    /// - Returns: The error message string if the field has an error, `nil` otherwise.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// ValidationTextField(
    ///     "Email",
    ///     text: $email,
    ///     validation: .email().required(),
    ///     fieldID: "email",
    ///     form: $form
    /// )
    ///
    /// // Later, retrieve the error using the fieldID
    /// if let error = form.error(for: "email") {
    ///     print("Email error: \(error)")
    /// }
    /// ```
    public func error(for fieldID: String) -> String? {
        errors[fieldID]
    }
    
    /// Returns whether a specific field is valid.
    ///
    /// - Parameter fieldID: The unique identifier of the field. This should match the `fieldID` parameter passed to `ValidationTextField` or `ValidationSecureField`. If `fieldID` was not provided, use the field's `title` (placeholder text).
    /// - Returns: `true` if the field is valid or has no validation state, `false` if it has errors.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// ValidationTextField(
    ///     "Email",
    ///     text: $email,
    ///     validation: .email().required(),
    ///     fieldID: "email",
    ///     form: $form
    /// )
    ///
    /// // Later, check validity using the fieldID
    /// if form.isValid(for: "email") {
    ///     print("Email is valid")
    /// }
    /// ```
    public func isValid(for fieldID: String) -> Bool {
        fieldStates[fieldID] ?? true
    }
    
    /// Registers a validation function for a field.
    ///
    /// This method is called automatically by `ValidationTextField` and `ValidationSecureField`
    /// when they are created with `.onSubmit` mode.
    ///
    /// - Parameters:
    ///   - field: The identifier of the field.
    ///   - validationFunction: A closure that performs validation for the field.
    func registerValidation(for field: String, validationFunction: @escaping () -> Void) {
        validationFunctions[field] = validationFunction
    }
    
    /// Unregisters a validation function for a field.
    ///
    /// This method is called automatically when a field is removed.
    ///
    /// - Parameter field: The identifier of the field.
    func unregisterValidation(for field: String) {
        validationFunctions.removeValue(forKey: field)
    }
    
    /// Validates all fields that are registered with `.onSubmit` mode.
    ///
    /// Call this method when the form is submitted to trigger validation for all fields
    /// that use `.onSubmit` mode.
    ///
    /// - Returns: `true` if all fields pass validation, `false` otherwise.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// struct MyForm: View {
    ///     @State private var form = FormValidationState()
    ///     @State private var email = ""
    ///     @State private var password = ""
    ///
    ///     var body: some View {
    ///         Form {
///             ValidationTextField(
///                 "Email",
///                 text: $email,
///                 validation: .email().required(),
///                 form: $form,
///                 validationMode: .onSubmit
///             )
///
///             ValidationSecureField(
///                 "Password",
///                 text: $password,
///                 validation: .required(),
///                 form: $form,
///                 validationMode: .onSubmit
///             )
    ///
    ///             Button("Submit") {
    ///                 if form.validateAll() {
    ///                     // Submit form
    ///                 }
    ///             }
    ///         }
    ///     }
    /// }
    /// ```
    @discardableResult
    public func validateAll() -> Bool {
        validationFunctions.values.forEach { $0() }
        return isValid
    }
}
