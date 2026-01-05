import Foundation
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
///         ValidatedTextField(
///             "Email",
///             text: $email,
///             validation: .email().required(),
///             form: $form
///         )
///
///         Button("Submit") {
///             if form.isValid {
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
    /// A dictionary mapping field identifiers to their error messages.
    ///
    /// Keys are field identifiers (typically the field title or a custom identifier),
    /// values are error messages displayed to the user.
    public private(set) var errors: [String: String] = [:]
    
    /// A dictionary mapping field identifiers to their validation state.
    ///
    /// Keys are field identifiers, values are `true` if the field is valid, `false` otherwise.
    public private(set) var fieldStates: [String: Bool] = [:]
    
    /// Returns `true` if all fields in the form are valid, `false` otherwise.
    ///
    /// Use this property to enable/disable submit buttons or determine if the form can be submitted.
    ///
    /// - Returns: `true` if all fields pass validation, `false` if any field has errors.
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
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// form.setError(for: "email", message: "Invalid email format")
    /// form.setError(for: "email", message: nil) // Clears the error
    /// ```
    public func setError(for field: String, message: String?) {
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
    /// ## Example Usage
    ///
    /// ```swift
    /// form.setValid(for: "email", isValid: true)
    /// ```
    public func setValid(for field: String, isValid: Bool) {
        if isValid {
            errors.removeValue(forKey: field)
        }
        fieldStates[field] = isValid
    }
    
    /// Clears all errors and validation states for all fields.
    ///
    /// Use this method to reset the form validation state.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// form.clearErrors() // Resets the entire form
    /// ```
    public func clearErrors() {
        errors.removeAll()
        fieldStates.removeAll()
    }
    
    /// Clears the error for a specific field and marks it as valid.
    ///
    /// - Parameter field: The identifier of the field to clear.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// form.clearError(for: "email")
    /// ```
    public func clearError(for field: String) {
        errors.removeValue(forKey: field)
        fieldStates[field] = true
    }
    
    /// Returns the error message for a specific field, if any.
    ///
    /// - Parameter field: The identifier of the field.
    /// - Returns: The error message string if the field has an error, `nil` otherwise.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// if let error = form.error(for: "email") {
    ///     print("Email error: \(error)")
    /// }
    /// ```
    public func error(for field: String) -> String? {
        errors[field]
    }
    
    /// Returns whether a specific field is valid.
    ///
    /// - Parameter field: The identifier of the field.
    /// - Returns: `true` if the field is valid or has no validation state, `false` if it has errors.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// if form.isValid(for: "email") {
    ///     print("Email is valid")
    /// }
    /// ```
    public func isValid(for field: String) -> Bool {
        fieldStates[field] ?? true
    }
}
