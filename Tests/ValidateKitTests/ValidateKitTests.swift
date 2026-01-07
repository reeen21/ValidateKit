import Testing
@testable import ValidateKit

// MARK: - ValidationResult Tests
@Test func testValidationResultValid() {
    let result = ValidationResult.valid
    #expect(result.isValid == true)
    #expect(result.errorMessage == nil)
}

@Test func testValidationResultInvalid() {
    let message = "This field is required"
    let result = ValidationResult.invalid(message)
    #expect(result.isValid == false)
    #expect(result.errorMessage == message)
}

// MARK: - String Validation Tests
@Test func testRequiredValidation() {
    let validation = ValidationRule.required()
    
    #expect(validation.validate("").isValid == false)
    #expect(validation.validate("   ").isValid == false)
    #expect(validation.validate("test").isValid == true)
}

@Test func testEmailValidation() {
    let validation = ValidationRule.email()
    
    #expect(validation.validate("test@example.com").isValid == true)
    #expect(validation.validate("invalid").isValid == false)
    #expect(validation.validate("test@").isValid == false)
    #expect(validation.validate("@example.com").isValid == false)
}

@Test func testMinLengthValidation() {
    let validation = ValidationRule.required()
        .minLength(5, message: "Too short")
    
    #expect(validation.validate("test").isValid == false)
    #expect(validation.validate("test123").isValid == true)
}

@Test func testMaxLengthValidation() {
    let validation = ValidationRule.required()
        .maxLength(5, message: "Too long")
    
    #expect(validation.validate("test").isValid == true)
    #expect(validation.validate("test123").isValid == false)
}

@Test func testEmailAndRequiredCombination() {
    let validation = ValidationRule
        .email(message: "Invalid email format")
        .required(message: "Email is required")
    
    #expect(validation.validate("").isValid == false)
    #expect(validation.validate("invalid").isValid == false)
    #expect(validation.validate("test@example.com").isValid == true)
}

@Test func testPasswordValidation() {
    let validation = ValidationRule
        .required(message: "Password is required")
        .minLength(8, message: "Password must be at least 8 characters")
        .containsUppercase(message: "Password must contain an uppercase letter")
        .containsNumber(message: "Password must contain a number")
    
    #expect(validation.validate("").isValid == false)
    #expect(validation.validate("short").isValid == false)
    #expect(validation.validate("nouppercase123").isValid == false)
    #expect(validation.validate("NONUMBER").isValid == false)
    #expect(validation.validate("ValidPass123").isValid == true)
}

@Test func testURLValidation() {
    let validation = ValidationRule.url()
    
    #expect(validation.validate("https://example.com").isValid == true)
    #expect(validation.validate("http://example.com").isValid == true)
    #expect(validation.validate("invalid").isValid == false)
    #expect(validation.validate("not-a-url").isValid == false)
}

@Test func testUsernameValidation() {
    let validation = ValidationRule.username()
    
    #expect(validation.validate("username123").isValid == true)
    #expect(validation.validate("user_name").isValid == true)
    #expect(validation.validate("user-name").isValid == false)
    #expect(validation.validate("user name").isValid == false)
}

@Test func testAlphanumericValidation() {
    let validation = ValidationRule
        .required()
        .alphanumeric(message: "Only alphanumeric characters allowed")
    
    #expect(validation.validate("abc123").isValid == true)
    #expect(validation.validate("abc_123").isValid == false)
    #expect(validation.validate("abc-123").isValid == false)
}

@Test func testMatchesValidation() {
    let validation = ValidationRule
        .required()
        .matches(#"^\d{4}-\d{2}-\d{2}$"#, message: "Must be in YYYY-MM-DD format")
    
    #expect(validation.validate("2024-01-15").isValid == true)
    #expect(validation.validate("2024/01/15").isValid == false)
    #expect(validation.validate("24-01-15").isValid == false)
    #expect(validation.validate("invalid").isValid == false)
}

@Test func testMatchesWithInvalidPattern() {
    // Invalid regex pattern should fail validation
    let validation = ValidationRule
        .required()
        .matches("[invalid", message: "Invalid format")
    
    // Even with invalid pattern, validation should fail gracefully
    #expect(validation.validate("test").isValid == false)
}

@Test func testCustomValidation() {
    let validation = ValidationRule.custom { value in
        value.count % 2 == 0 ? .valid : .invalid("Length must be even")
    }
    
    #expect(validation.validate("ab").isValid == true)
    #expect(validation.validate("abc").isValid == false)
}

@Test func testAndCombination() {
    let validation1 = ValidationRule.required(message: "Required")
    let validation2 = ValidationRule.custom { $0.count >= 5 ? .valid : .invalid("Too short") }
    
    let combined = validation1.and(validation2)
    
    #expect(combined.validate("").isValid == false)
    #expect(combined.validate("abc").isValid == false)
    #expect(combined.validate("abcde").isValid == true)
}

@Test func testOrCombination() {
    let emailValidation = ValidationRule.email(message: "Invalid email")
    let phoneValidation = ValidationRule.phoneNumber(message: "Invalid phone")
    
    let combined = emailValidation.or(phoneValidation)
    
    #expect(combined.validate("test@example.com").isValid == true)
    #expect(combined.validate("123-456-7890").isValid == true)
    #expect(combined.validate("invalid").isValid == false)
    #expect(combined.validate("").isValid == false)
}

@Test func testWhenConditionalValidation() {
    let validation = ValidationRule
        .required(message: "Required")
        .when({ !$0.isEmpty }) { _ in
            ValidationRule.required().minLength(5, message: "Must be at least 5 characters")
        }
    
    #expect(validation.validate("").isValid == false)
    #expect(validation.validate("abc").isValid == false)
    #expect(validation.validate("abcde").isValid == true)
}

// MARK: - Int Validation Tests
@Test func testIntMinValidation() {
    let validation = Validation<Int>.min(10, message: "Must be at least 10")
    
    #expect(validation.validate(5).isValid == false)
    #expect(validation.validate(10).isValid == true)
    #expect(validation.validate(15).isValid == true)
}

@Test func testIntMaxValidation() {
    let validation = Validation<Int>.max(10, message: "Must be at most 10")
    
    #expect(validation.validate(5).isValid == true)
    #expect(validation.validate(10).isValid == true)
    #expect(validation.validate(15).isValid == false)
}

@Test func testIntRangeValidation() {
    let validation = Validation<Int>.range(1...10, message: "Must be between 1 and 10")
    
    #expect(validation.validate(0).isValid == false)
    #expect(validation.validate(5).isValid == true)
    #expect(validation.validate(10).isValid == true)
    #expect(validation.validate(11).isValid == false)
}

// MARK: - FormValidationState Tests
@MainActor @Test func testFormValidationState() {
    let state = FormValidationState()
    
    #expect(state.isValid == true)
    #expect(state.errors.isEmpty == true)
    
    state.setError(for: "email", message: "Invalid email")
    #expect(state.isValid == false)
    #expect(state.error(for: "email") == "Invalid email")
    
    state.setValid(for: "email", isValid: true)
    #expect(state.isValid == true)
    #expect(state.error(for: "email") == nil)
    
    state.clearErrors()
    #expect(state.errors.isEmpty == true)
}
