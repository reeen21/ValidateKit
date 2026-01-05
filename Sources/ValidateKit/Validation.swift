import Foundation

/// A validation rule that can be applied to a value of type `Value`.
///
/// `Validation` provides a declarative way to define validation rules that can be
/// chained together and combined using logical operators.
///
/// ## Example Usage
///
/// ```swift
/// // Simple validation
/// let emailValidation = Validation<String>.email()
///
/// // Chained validations
/// let passwordValidation = Validation<String>
///     .required("Password is required")
///     .minLength(8, message: "Password must be at least 8 characters")
///     .containsUppercase("Password must contain an uppercase letter")
///
/// // Custom validation
/// let customValidation = Validation<String>.custom { value in
///     value.count % 2 == 0 ? .valid : .invalid("Length must be even")
/// }
/// ```
public struct Validation<Value> {
    /// A closure that validates a value and returns a `ValidationResult`.
    public typealias Validator = (Value) -> ValidationResult
    
    private let validator: Validator
    
    /// Creates a new validation rule with the provided validator closure.
    ///
    /// - Parameter validator: A closure that takes a value and returns a `ValidationResult`.
    public init(_ validator: @escaping Validator) {
        self.validator = validator
    }
    
    /// Validates the given value using this validation rule.
    ///
    /// - Parameter value: The value to validate.
    /// - Returns: A `ValidationResult` indicating whether the value passed validation.
    public func validate(_ value: Value) -> ValidationResult {
        validator(value)
    }
    
    /// Combines this validation with another using AND logic.
    ///
    /// Both validations must pass for the combined validation to succeed.
    /// If the first validation fails, its error message is returned.
    ///
    /// - Parameter other: Another validation rule to combine with.
    /// - Returns: A new validation that requires both validations to pass.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let validation = Validation<String>.required()
    ///     .and(Validation<String>.email())
    /// ```
    public func and(_ other: Validation<Value>) -> Validation<Value> {
        Validation { value in
            let result1 = self.validate(value)
            guard result1.isValid else {
                return result1
            }
            return other.validate(value)
        }
    }
    
    /// Combines this validation with another using OR logic.
    ///
    /// At least one validation must pass for the combined validation to succeed.
    /// If both fail, the error message from the first validation is returned.
    ///
    /// - Parameter other: Another validation rule to combine with.
    /// - Returns: A new validation that requires at least one validation to pass.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let validation = Validation<String>.email()
    ///     .or(Validation<String>.phoneNumber())
    /// ```
    public func or(_ other: Validation<Value>) -> Validation<Value> {
        Validation { value in
            let result1 = self.validate(value)
            if result1.isValid {
                return result1
            }
            let result2 = other.validate(value)
            if result2.isValid {
                return result2
            }
            // If both are invalid, return the first error message
            return result1
        }
    }
    
    /// Applies a validation rule conditionally based on a predicate.
    ///
    /// The validation is only applied if the previous validation passes and the condition returns `true`.
    /// If the previous validation fails, its error is returned. If the condition returns `false`, validation passes.
    ///
    /// - Parameters:
    ///   - condition: A closure that determines whether to apply the validation.
    ///   - validation: A closure that returns the validation to apply when the condition is met.
    /// - Returns: A new validation that applies conditionally.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let validation = Validation<String>
    ///     .required("Required")
    ///     .when({ !$0.isEmpty }) { _ in
    ///         Validation<String>.required().minLength(5, message: "Must be at least 5 characters")
    ///     }
    /// ```
    public func when(_ condition: @escaping (Value) -> Bool, _ validation: @escaping (Value) -> Validation<Value>) -> Validation<Value> {
        Validation { value in
            // First check the previous validation
            let previousResult = self.validate(value)
            guard previousResult.isValid else {
                return previousResult
            }
            // Only apply conditional validation if previous validation passed
            if condition(value) {
                return validation(value).validate(value)
            }
            return .valid
        }
    }
}

// MARK: - String Validation Extensions
extension Validation where Value == String {
    /// Validates that a string is not empty (after trimming whitespace).
    ///
    /// - Parameter message: The error message to display if validation fails. Defaults to "This field is required".
    /// - Returns: A validation rule that checks for required input.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// let validation = Validation<String>.required("Email is required")
    /// let result = validation.validate("") // Returns .invalid("Email is required")
    /// ```
    public static func required(message: String = "This field is required") -> Validation<String> {
        Validation { value in
            value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ? .invalid(message)
                : .valid
        }
    }
    
    /// Validates that a string has a minimum length.
    ///
    /// This method chains with existing validations using AND logic.
    ///
    /// - Parameters:
    ///   - length: The minimum number of characters required.
    ///   - message: The error message to display if validation fails.
    /// - Returns: A validation rule that checks for minimum length.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// let validation = Validation<String>.required()
    ///     .minLength(5, message: "Must be at least 5 characters")
    /// ```
    public func minLength(_ length: Int, message: String) -> Validation<String> {
        self.and(Validation { value in
            value.count >= length ? .valid : .invalid(message)
        })
    }
    
    /// Validates that a string has a maximum length.
    ///
    /// This method chains with existing validations using AND logic.
    ///
    /// - Parameters:
    ///   - length: The maximum number of characters allowed.
    ///   - message: The error message to display if validation fails.
    /// - Returns: A validation rule that checks for maximum length.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// let validation = Validation<String>.required()
    ///     .maxLength(100, message: "Must be at most 100 characters")
    /// ```
    public func maxLength(_ length: Int, message: String) -> Validation<String> {
        self.and(Validation { value in
            value.count <= length ? .valid : .invalid(message)
        })
    }
    
    /// Validates that a string matches a regular expression pattern.
    ///
    /// This method chains with existing validations using AND logic.
    ///
    /// - Parameters:
    ///   - pattern: A regular expression pattern to match against.
    ///   - message: The error message to display if validation fails.
    /// - Returns: A validation rule that checks for pattern matching.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// let validation = Validation<String>
    ///     .required()
    ///     .matches(#"^\d{4}-\d{2}-\d{2}$"#, message: "Must be in YYYY-MM-DD format")
    /// ```
    public func matches(_ pattern: String, message: String) -> Validation<String> {
        self.and(Validation { value in
            let regex = try? NSRegularExpression(pattern: pattern)
            let range = NSRange(location: 0, length: value.utf16.count)
            let matches = regex?.firstMatch(in: value, options: [], range: range)
            return matches != nil ? .valid : .invalid(message)
        })
    }
    
    /// Creates a custom validation rule with a custom validator closure.
    ///
    /// - Parameter validator: A closure that takes a string value and returns a `ValidationResult`.
    /// - Returns: A validation rule using the custom validator.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// let validation = Validation<String>.custom { value in
    ///     value.count % 2 == 0 ? .valid : .invalid("Length must be even")
    /// }
    /// ```
    public static func custom(_ validator: @escaping Validator) -> Validation<String> {
        Validation(validator)
    }
}

// MARK: - Integer Validation Extensions
extension Validation where Value == Int {
    /// Validates that an integer is greater than or equal to a minimum value.
    ///
    /// - Parameters:
    ///   - value: The minimum value allowed.
    ///   - message: The error message to display if validation fails.
    /// - Returns: A validation rule that checks for minimum value.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// let validation = Validation<Int>.min(18, message: "Must be at least 18")
    /// ```
    public static func min(_ value: Int, message: String) -> Validation<Int> {
        Validation { input in
            input >= value ? .valid : .invalid(message)
        }
    }
    
    /// Validates that an integer is less than or equal to a maximum value.
    ///
    /// - Parameters:
    ///   - value: The maximum value allowed.
    ///   - message: The error message to display if validation fails.
    /// - Returns: A validation rule that checks for maximum value.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// let validation = Validation<Int>.max(120, message: "Must be at most 120")
    /// ```
    public static func max(_ value: Int, message: String) -> Validation<Int> {
        Validation { input in
            input <= value ? .valid : .invalid(message)
        }
    }
    
    /// Validates that an integer is within a closed range.
    ///
    /// - Parameters:
    ///   - range: A closed range that the value must fall within.
    ///   - message: The error message to display if validation fails.
    /// - Returns: A validation rule that checks for range inclusion.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// let validation = Validation<Int>.range(1...100, message: "Must be between 1 and 100")
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
    /// let validation = Validation<Int>.custom { value in
    ///     value % 2 == 0 ? .valid : .invalid("Must be even")
    /// }
    /// ```
    public static func custom(_ validator: @escaping Validator) -> Validation<Int> {
        Validation(validator)
    }
}
