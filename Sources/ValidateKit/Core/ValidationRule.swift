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
    
    /// Creates a minimum length validation.
    ///
    /// This method automatically includes a required check, so you don't need to call `.required()` separately.
    ///
    /// - Parameters:
    ///   - length: The minimum number of characters required.
    ///   - message: The error message to display if validation fails.
    /// - Returns: A validation rule that checks for minimum length.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// let validation = ValidationRule.minLength(5, message: "Must be at least 5 characters")
    /// ```
    public static func minLength(_ length: Int, message: String) -> Validation<String> {
        required().minLength(length, message: message)
    }
    
    /// Creates a maximum length validation.
    ///
    /// This method automatically includes a required check, so you don't need to call `.required()` separately.
    ///
    /// - Parameters:
    ///   - length: The maximum number of characters allowed.
    ///   - message: The error message to display if validation fails.
    /// - Returns: A validation rule that checks for maximum length.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// let validation = ValidationRule.maxLength(100, message: "Must be at most 100 characters")
    /// ```
    public static func maxLength(_ length: Int, message: String) -> Validation<String> {
        required().maxLength(length, message: message)
    }
    
    /// Creates a pattern matching validation.
    ///
    /// This method automatically includes a required check, so you don't need to call `.required()` separately.
    ///
    /// - Parameters:
    ///   - pattern: A regular expression pattern to match against.
    ///   - message: The error message to display if validation fails.
    /// - Returns: A validation rule that checks for pattern matching.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// let validation = ValidationRule.matches(#"^\d{4}-\d{2}-\d{2}$"#, message: "Must be in YYYY-MM-DD format")
    /// ```
    public static func matches(_ pattern: String, message: String) -> Validation<String> {
        required().matches(pattern, message: message)
    }
    
    // MARK: - Integer Validations
    
    /// Creates a minimum value validation for integers.
    ///
    /// - Parameters:
    ///   - value: The minimum value allowed.
    ///   - message: The error message to display if validation fails.
    /// - Returns: A validation rule that checks for minimum value.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// let validation = ValidationRule.min(18, message: "Must be at least 18")
    /// ```
    public static func min(_ value: Int, message: String) -> Validation<Int> {
        Validation { input in
            input >= value ? .valid : .invalid(message)
        }
    }
    
    /// Creates a maximum value validation for integers.
    ///
    /// - Parameters:
    ///   - value: The maximum value allowed.
    ///   - message: The error message to display if validation fails.
    /// - Returns: A validation rule that checks for maximum value.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// let validation = ValidationRule.max(120, message: "Must be at most 120")
    /// ```
    public static func max(_ value: Int, message: String) -> Validation<Int> {
        Validation { input in
            input <= value ? .valid : .invalid(message)
        }
    }
    
    /// Creates a range validation for integers.
    ///
    /// - Parameters:
    ///   - range: A closed range that the value must fall within.
    ///   - message: The error message to display if validation fails.
    /// - Returns: A validation rule that checks for range inclusion.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// let validation = ValidationRule.range(1...100, message: "Must be between 1 and 100")
    /// ```
    public static func range(_ range: ClosedRange<Int>, message: String) -> Validation<Int> {
        Validation { input in
            range.contains(input) ? .valid : .invalid(message)
        }
    }
    
    /// Creates a custom validation rule for integers with a custom validator closure.
    ///
    /// - Parameter validator: A closure that takes an integer value and returns a `ValidationResult`.
    /// - Returns: A validation rule using the custom validator.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// let validation = ValidationRule.custom { (value: Int) in
    ///     value % 2 == 0 ? .valid : .invalid("Must be even")
    /// }
    /// ```
    public static func custom(_ validator: @escaping (Int) -> ValidationResult) -> Validation<Int> {
        Validation(validator)
    }
}
