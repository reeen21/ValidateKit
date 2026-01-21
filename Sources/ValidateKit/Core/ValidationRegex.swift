import Foundation
import RegexBuilder

/// Regex patterns for common validation rules.
///
/// These regex patterns are created using RegexBuilder for type-safe pattern matching.
enum ValidationRegex {
    /// Validates an email address format.
    ///
    /// Allows alphanumeric characters, dots, underscores, percent signs, plus signs, and hyphens
    /// before the @ symbol, followed by a domain name with at least 2 characters.
    ///
    /// - Parameter value: The string to validate.
    /// - Returns: `true` if the value matches the email pattern, `false` otherwise.
    static func matchesEmail(_ value: String) -> Bool {
        let localPart = Regex {
            OneOrMore {
                CharacterClass(
                    .word,
                    .anyOf("._%+-")
                )
            }
        }
        
        let domain = Regex {
            OneOrMore {
                CharacterClass(
                    .word,
                    .anyOf(".-")
                )
            }
            "."
            Repeat(2...) {
                .word
            }
        }
        
        let emailRegex = Regex {
            Anchor.startOfLine
            localPart
            "@"
            domain
            Anchor.endOfLine
        }
        
        return value.wholeMatch(of: emailRegex) != nil
    }
    
    /// Validates a phone number format.
    ///
    /// Allows digits, spaces, hyphens, parentheses, and plus signs.
    ///
    /// - Parameter value: The string to validate.
    /// - Returns: `true` if the value matches the phone number pattern, `false` otherwise.
    static func matchesPhoneNumber(_ value: String) -> Bool {
        let phoneRegex = Regex {
            Anchor.startOfLine
            OneOrMore {
                CharacterClass(
                    .digit,
                    .whitespace,
                    .anyOf("-()+")
                )
            }
            Anchor.endOfLine
        }
        
        return value.wholeMatch(of: phoneRegex) != nil
    }
    
    /// Validates a username format.
    ///
    /// Allows only letters, numbers, and underscores.
    ///
    /// - Parameter value: The string to validate.
    /// - Returns: `true` if the value matches the username pattern, `false` otherwise.
    static func matchesUsername(_ value: String) -> Bool {
        let usernameRegex = Regex {
            Anchor.startOfLine
            OneOrMore {
                CharacterClass(.word)
            }
            Anchor.endOfLine
        }
        
        return value.wholeMatch(of: usernameRegex) != nil
    }
    
    /// Validates an alphanumeric format.
    ///
    /// Allows only letters and numbers (no underscores).
    ///
    /// - Parameter value: The string to validate.
    /// - Returns: `true` if the value matches the alphanumeric pattern, `false` otherwise.
    static func matchesAlphanumeric(_ value: String) -> Bool {
        let alphanumericRegex = Regex {
            Anchor.startOfLine
            OneOrMore {
                ChoiceOf {
                    CharacterClass("a"..."z")
                    CharacterClass("A"..."Z")
                    CharacterClass(.digit)
                }
            }
            Anchor.endOfLine
        }
        
        return value.wholeMatch(of: alphanumericRegex) != nil
    }
    
    /// Validates a string against a regex pattern string.
    ///
    /// - Parameters:
    ///   - value: The string to validate.
    ///   - pattern: The regex pattern string to match against.
    /// - Returns: `true` if the value matches the pattern, `false` otherwise.
    static func matches(_ value: String, pattern: String) -> Bool {
        guard let regex = try? Regex(pattern) else {
            return false
        }
        return value.wholeMatch(of: regex) != nil
    }
}
