import Foundation

/// Represents the result of a validation operation.
///
/// Use `ValidationResult` to determine whether a value passes validation and to retrieve
/// error messages when validation fails.
///
/// ## Example Usage
///
/// ```swift
/// let result = validation.validate("test@example.com")
/// if result.isValid {
///     print("Validation passed")
/// } else {
///     print("Error: \(result.errorMessage ?? "Unknown error")")
/// }
/// ```
public enum ValidationResult {
    /// The value passed validation.
    case valid
    
    /// The value failed validation with the provided error message.
    /// - Parameter message: A human-readable error message describing why validation failed.
    case invalid(String)
    
    /// Returns `true` if validation passed, `false` otherwise.
    ///
    /// - Returns: `true` for `.valid`, `false` for `.invalid(_)`.
    public var isValid: Bool {
        switch self {
        case .valid:
            return true
        case .invalid:
            return false
        }
    }
    
    /// Returns the error message if validation failed, `nil` otherwise.
    ///
    /// - Returns: The error message string for `.invalid(_)`, `nil` for `.valid`.
    public var errorMessage: String? {
        switch self {
        case .valid:
            return nil
        case .invalid(let message):
            return message
        }
    }
}
