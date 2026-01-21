import Foundation

// MARK: - String Validation Rules
extension Validation where Value == String {
    /// Creates an email format validation.
    ///
    /// This static method allows starting a validation chain.
    /// Uses a standard email regex pattern to validate the format.
    ///
    /// - Parameter message: The error message to display if validation fails. Defaults to "Invalid email format".
    /// - Returns: A validation rule that checks for email format.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// let validation = Validation<String>.email()
    ///     .required("Email is required")
    /// ```
    public static func email(message: String = "Invalid email format") -> Validation<String> {
        ValidationRule.email(message: message)
    }
    
    /// Validates that a string matches a valid email address format.
    ///
    /// This instance method allows chaining from other validation methods.
    /// Uses a standard email regex pattern to validate the format.
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
    public func email(message: String = "Invalid email format") -> Validation<String> {
        self.and(ValidationRule.email(message: message))
    }
    
    /// Validates that a string contains only alphanumeric characters (letters and numbers).
    ///
    /// This method chains with existing validations using AND logic.
    /// Does not allow underscores or other special characters.
    ///
    /// - Parameter message: The error message to display if validation fails.
    /// - Returns: A validation rule that checks for alphanumeric characters only.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// let validation = ValidationRule.required()
    ///     .alphanumeric(message: "Only letters and numbers are allowed")
    /// ```
    public func alphanumeric(message: String) -> Validation<String> {
        self.and(Validation { value in
            ValidationRegex.matchesAlphanumeric(value)
                ? .valid
                : .invalid(message)
        })
    }

    /// Validates that a string contains at least one uppercase letter.
    ///
    /// This method chains with existing validations using AND logic.
    /// Commonly used for password validation.
    ///
    /// - Parameter message: The error message to display if validation fails.
    /// - Returns: A validation rule that checks for uppercase letters.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// let validation = ValidationRule.required("Password is required")
    ///     .containsUppercase("Password must contain an uppercase letter")
    /// ```
    public func containsUppercase(message: String) -> Validation<String> {
        self.and(Validation { value in
            value.rangeOfCharacter(from: CharacterSet.uppercaseLetters) != nil
                ? .valid
                : .invalid(message)
        })
    }
    
    /// Validates that a string contains at least one lowercase letter.
    ///
    /// This method chains with existing validations using AND logic.
    /// Commonly used for password validation.
    ///
    /// - Parameter message: The error message to display if validation fails.
    /// - Returns: A validation rule that checks for lowercase letters.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// let validation = ValidationRule.required("Password is required")
    ///     .containsLowercase("Password must contain a lowercase letter")
    /// ```
    public func containsLowercase(message: String) -> Validation<String> {
        self.and(Validation { value in
            value.rangeOfCharacter(from: CharacterSet.lowercaseLetters) != nil
                ? .valid
                : .invalid(message)
        })
    }
    
    /// Validates that a string contains at least one numeric digit.
    ///
    /// This method chains with existing validations using AND logic.
    /// Commonly used for password validation.
    ///
    /// - Parameter message: The error message to display if validation fails.
    /// - Returns: A validation rule that checks for numeric digits.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// let validation = ValidationRule.required("Password is required")
    ///     .containsNumber("Password must contain a number")
    /// ```
    public func containsNumber(message: String) -> Validation<String> {
        self.and(Validation { value in
            value.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil
                ? .valid
                : .invalid(message)
        })
    }
    
    /// Validates that a string contains at least one special character.
    ///
    /// Special characters include: `!@#$%^&*()_+-=[]{}|;:,.<>?`
    ///
    /// This method chains with existing validations using AND logic.
    /// Commonly used for password validation.
    ///
    /// - Parameter message: The error message to display if validation fails.
    /// - Returns: A validation rule that checks for special characters.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// let validation = ValidationRule.required("Password is required")
    ///     .containsSpecialCharacter("Password must contain a special character")
    /// ```
    public func containsSpecialCharacter(message: String) -> Validation<String> {
        self.and(Validation { value in
            let specialCharacterSet = CharacterSet(charactersIn: "!@#$%^&*()_+-=[]{}|;:,.<>?")
            return value.rangeOfCharacter(from: specialCharacterSet) != nil
                ? .valid
                : .invalid(message)
        })
    }
}
