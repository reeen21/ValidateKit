import Foundation

// MARK: - String Validation Rules
extension Validation where Value == String {
    /// Email format validation (available as a property).
    ///
    /// Use this property for a concise syntax when chaining validations.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// let validation = Validation<String>.email
    ///     .required("Email is required")
    /// ```
    public static var email: Validation<String> {
        .email()
    }
    
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
        Validation { value in
            let emailRegex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
            let regex = try? NSRegularExpression(pattern: emailRegex)
            let range = NSRange(location: 0, length: value.utf16.count)
            let matches = regex?.firstMatch(in: value, options: [], range: range)
            return matches != nil ? .valid : .invalid(message)
        }
    }
    
    /// URL format validation (available as a property).
    ///
    /// Use this property for a concise syntax when chaining validations.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// let validation = Validation<String>.url
    ///     .required("URL is required")
    /// ```
    public static var url: Validation<String> {
        .url()
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
        Validation { value in
            guard let url = URL(string: value),
                  url.scheme != nil,
                  url.host != nil else {
                return .invalid(message)
            }
            return .valid
        }
    }
    
    /// Phone number format validation (available as a property).
    ///
    /// Use this property for a concise syntax when chaining validations.
    public static var phoneNumber: Validation<String> {
        .phoneNumber()
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
        Validation { value in
            let phoneRegex = #"^[\d\s\-\(\)\+]+$"#
            let regex = try? NSRegularExpression(pattern: phoneRegex)
            let range = NSRange(location: 0, length: value.utf16.count)
            let matches = regex?.firstMatch(in: value, options: [], range: range)
            return matches != nil && value.count >= 10 ? .valid : .invalid(message)
        }
    }
    
    /// Username format validation (available as a property).
    ///
    /// Use this property for a concise syntax when chaining validations.
    public static var username: Validation<String> {
        .username()
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
        Validation { value in
            let usernameRegex = #"^[a-zA-Z0-9_]+$"#
            let regex = try? NSRegularExpression(pattern: usernameRegex)
            let range = NSRange(location: 0, length: value.utf16.count)
            let matches = regex?.firstMatch(in: value, options: [], range: range)
            return matches != nil ? .valid : .invalid(message)
        }
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
    
    /// Password validation (available as a property).
    ///
    /// Use this property as a starting point for password validation chains.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// let validation = Validation<String>.password
    ///     .required("Password is required")
    ///     .minLength(8, message: "Password must be at least 8 characters")
    ///     .containsUppercase("Password must contain an uppercase letter")
    /// ```
    public static var password: Validation<String> {
        .password()
    }
    
    /// Creates a base password validation rule.
    ///
    /// This is a placeholder that always passes. Use it as a starting point
    /// for chaining password-specific validation rules.
    ///
    /// - Parameter message: Unused, but kept for API consistency. Defaults to "Invalid password format".
    /// - Returns: A validation rule that always passes (use with chained password rules).
    public static func password(message: String = "Invalid password format") -> Validation<String> {
        Validation { _ in
            .valid
        }
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
    /// let validation = Validation<String>.password()
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
    /// let validation = Validation<String>.password()
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
    /// let validation = Validation<String>.password()
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
    /// let validation = Validation<String>.password()
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
