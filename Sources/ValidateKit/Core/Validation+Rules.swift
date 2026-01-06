import Foundation

// MARK: - String Validation Rules
extension Validation where Value == String {
    /// Validates that a string matches a valid email address format.
    ///
    /// Uses a standard email regex pattern to validate the format.
    ///
    /// - Parameter message: The error message to display if validation fails. Defaults to "Invalid email format".
    /// - Returns: A validation rule that checks for email format.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// let validation = Validation<String>.email("Please enter a valid email address")
    /// let result = validation.validate("test@example.com") // Returns .valid
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
    /// let validation = Validation<String>.email()
    ///     .required("Email is required")
    /// ```
    public func email(message: String = "Invalid email format") -> Validation<String> {
        self.and(ValidationRule.email(message: message))
    }
    
    /// Validates that a string is a valid URL.
    ///
    /// Checks that the string can be parsed as a URL and contains both a scheme and host.
    ///
    /// - Parameter message: The error message to display if validation fails. Defaults to "Invalid URL format".
    /// - Returns: A validation rule that checks for URL format.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// let validation = Validation<String>.url("Please enter a valid URL")
    /// let result = validation.validate("https://example.com") // Returns .valid
    /// ```
    public static func url(message: String = "Invalid URL format") -> Validation<String> {
        ValidationRule.url(message: message)
    }
    
    /// Validates that a string matches a basic phone number format.
    ///
    /// Accepts digits, spaces, hyphens, parentheses, and plus signs.
    /// Requires a minimum length of 10 characters.
    ///
    /// - Parameter message: The error message to display if validation fails. Defaults to "Invalid phone number".
    /// - Returns: A validation rule that checks for phone number format.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// let validation = Validation<String>.phoneNumber("Please enter a valid phone number")
    /// let result = validation.validate("123-456-7890") // Returns .valid
    /// ```
    public static func phoneNumber(message: String = "Invalid phone number") -> Validation<String> {
        ValidationRule.phoneNumber(message: message)
    }
    
    /// Validates that a string contains only alphanumeric characters and underscores.
    ///
    /// Useful for validating usernames that should only contain letters, numbers, and underscores.
    ///
    /// - Parameter message: The error message to display if validation fails. Defaults to "Username can only contain letters, numbers, and underscores".
    /// - Returns: A validation rule that checks for username format.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// let validation = Validation<String>.username("Username can only contain letters, numbers, and underscores")
    /// let result = validation.validate("user_name123") // Returns .valid
    /// ```
    public static func username(message: String = "Username can only contain letters, numbers, and underscores") -> Validation<String> {
        ValidationRule.username(message: message)
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
    /// let validation = Validation<String>
    ///     .required()
    ///     .alphanumeric(message: "Only letters and numbers are allowed")
    /// ```
    public func alphanumeric(message: String) -> Validation<String> {
        self.and(Validation { value in
            let alphanumericRegex = #"^[a-zA-Z0-9]+$"#
            let regex = try? NSRegularExpression(pattern: alphanumericRegex)
            let range = NSRange(location: 0, length: value.utf16.count)
            let matches = regex?.firstMatch(in: value, options: [], range: range)
            return matches != nil ? .valid : .invalid(message)
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
    /// let validation = Validation<String>.required("Password is required")
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
    /// let validation = Validation<String>.required("Password is required")
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
    /// let validation = Validation<String>.required("Password is required")
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
    /// let validation = Validation<String>.required("Password is required")
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
