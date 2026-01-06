import Foundation

/// A namespace for creating validation rules with a concise, static API.
///
/// Use `ValidationRule` to create validation rules without explicitly specifying `Validation<String>`.
/// This provides a clear namespace that distinguishes library functions from app functions.
///
/// ## Example Usage
///
/// ```swift
/// // Clean and concise API with explicit namespace
/// let emailValidation = ValidationRule.email()
///     .required("Email is required")
///
/// // In ValidatedTextField, you can use type inference (no ValidationRule prefix needed)
/// ValidatedTextField(
///     "Email",
///     text: $email,
///     validation: .email()
///         .required("Email is required")
/// )
/// ```
public enum ValidationRule {
    /// Creates a required field validation.
    ///
    /// - Parameter message: The error message to display if validation fails. Defaults to "This field is required".
    /// - Returns: A validation rule that checks for required input.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// let validation = ValidationRule.required("Email is required")
    ///     .email()
    /// ```
    public static func required(message: String = "This field is required") -> Validation<String> {
        Validation { value in
            value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ? .invalid(message)
                : .valid
        }
    }
    
    /// Creates an email format validation.
    ///
    /// - Parameter message: The error message to display if validation fails. Defaults to "Invalid email format".
    /// - Returns: A validation rule that checks for email format.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// let validation = ValidationRule.email()
    ///     .required("Email is required")
    /// ```
    public static func email(message: String = "Invalid email format") -> Validation<String> {
        Validation { value in
            let emailRegex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
            let regex = try? NSRegularExpression(pattern: emailRegex)
            let range = NSRange(location: 0, length: value.utf16.count)
            let matches = regex?.firstMatch(in: value, options: [], range: range)
            return matches != nil ? .valid : .invalid(message)
        }
    }
    
    /// Creates a URL format validation.
    ///
    /// - Parameter message: The error message to display if validation fails. Defaults to "Invalid URL format".
    /// - Returns: A validation rule that checks for URL format.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// let validation = ValidationRule.url()
    ///     .required("URL is required")
    /// ```
    public static func url(message: String = "Invalid URL format") -> Validation<String> {
        Validation { value in
            guard let url = URL(string: value),
                  url.scheme != nil,
                  url.host != nil else {
                return .invalid(message)
            }
            return .valid
        }
    }
    
    /// Creates a phone number format validation.
    ///
    /// - Parameter message: The error message to display if validation fails. Defaults to "Invalid phone number".
    /// - Returns: A validation rule that checks for phone number format.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// let validation = ValidationRule.phoneNumber()
    ///     .required("Phone number is required")
    /// ```
    public static func phoneNumber(message: String = "Invalid phone number") -> Validation<String> {
        Validation { value in
            let phoneRegex = #"^[\d\s\-\(\)\+]+$"#
            let regex = try? NSRegularExpression(pattern: phoneRegex)
            let range = NSRange(location: 0, length: value.utf16.count)
            let matches = regex?.firstMatch(in: value, options: [], range: range)
            return matches != nil && value.count >= 10 ? .valid : .invalid(message)
        }
    }
    
    /// Creates a username format validation.
    ///
    /// - Parameter message: The error message to display if validation fails. Defaults to "Username can only contain letters, numbers, and underscores".
    /// - Returns: A validation rule that checks for username format.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// let validation = ValidationRule.username()
    ///     .required("Username is required")
    /// ```
    public static func username(message: String = "Username can only contain letters, numbers, and underscores") -> Validation<String> {
        Validation { value in
            let usernameRegex = #"^[a-zA-Z0-9_]+$"#
            let regex = try? NSRegularExpression(pattern: usernameRegex)
            let range = NSRange(location: 0, length: value.utf16.count)
            let matches = regex?.firstMatch(in: value, options: [], range: range)
            return matches != nil ? .valid : .invalid(message)
        }
    }

    /// Creates a custom validation rule with a custom validator closure.
    ///
    /// - Parameter validator: A closure that takes a string value and returns a `ValidationResult`.
    /// - Returns: A validation rule using the custom validator.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// let validation = ValidationRule.custom { value in
    ///     value.count % 2 == 0 ? .valid : .invalid("Length must be even")
    /// }
    /// ```
    public static func custom(_ validator: @escaping (String) -> ValidationResult) -> Validation<String> {
        Validation(validator)
    }
}

