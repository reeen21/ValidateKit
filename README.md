# ValidateKit

A powerful and flexible SwiftUI validation library for iOS 17+ that provides declarative validation rules, real-time validation feedback, and form-level validation state management.

## Features

- 🎯 **Declarative API** - Chain validation rules together with a fluent, easy-to-read syntax
- ⚡ **Real-time Validation** - Validate on change, blur, submit
- 📱 **SwiftUI Integration** - Built-in `ValidatedTextField` and `ValidatedSecureField` components
- 🔗 **Form State Management** - Track validation state across multiple fields
- 🎨 **Customizable** - Configure validation modes, error positions, and debounce intervals
- 🔧 **Extensible** - Create custom validation rules with closures
- ♿ **Accessible** - Built-in accessibility support

## Requirements

- iOS 17.0+
- Swift 6.2+
- Xcode 15.0+

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/reeen21/ValidateKit.git", from: "1.0.0")
]
```

Or add it through Xcode:
1. File → Add Package Dependencies
2. Enter the repository URL
3. Select the version you want to use

## Quick Start

### Basic Usage

```swift
import SwiftUI
import ValidateKit

struct LoginForm: View {
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        Form {
            ValidatedTextField(
                "Email",
                text: $email,
                validation: ValidationRule.email()
                    .required(message: "Email is required")
            )
            
            ValidatedSecureField(
                "Password",
                text: $password,
                validation: ValidationRule
                    .required(message: "Password is required")
                    .minLength(8, message: "Password must be at least 8 characters")
            )
        }
    }
}
```

### Form-Level Validation

```swift
struct RegistrationForm: View {
    @State private var form = FormValidationState()
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    var body: some View {
        Form {
            ValidatedTextField(
                "Email",
                text: $email,
                validation: ValidationRule.email().required(),
                form: $form
            )
            
            ValidatedSecureField(
                "Password",
                text: $password,
                validation: ValidationRule
                    .required(message: "Password is required")
                    .minLength(8, message: "Password must be at least 8 characters")
                    .containsUppercase(message: "Password must contain an uppercase letter")
                    .containsNumber(message: "Password must contain a number"),
                form: $form
            )
            
            ValidatedSecureField(
                "Confirm Password",
                text: $confirmPassword,
                validation: ValidationRule
                    .required(message: "Confirm password is required")
                    .custom { [password] confirm in
                        confirm == password ? .valid : .invalid("Passwords do not match")
                    },
                form: $form
            )
            
            Button("Submit") {
                if form.isValid {
                    // Submit form
                }
            }
            .disabled(!form.isValid)
        }
    }
}
```

## Validation Rules

### Built-in String Validations

#### Required Field
```swift
ValidationRule.required(message: "This field is required")
```

#### Email Format
```swift
ValidationRule.email("Invalid email format")
```

#### URL Format
```swift
ValidationRule.url("Invalid URL format")
```

#### Phone Number
```swift
ValidationRule.phoneNumber("Invalid phone number")
```

#### Username
```swift
ValidationRule.username("Username can only contain letters, numbers, and underscores")
```

#### Length Constraints
```swift
// Minimum length (automatically includes required check)
ValidationRule.minLength(8, message: "Must be at least 8 characters")

// Or chain with required for custom message
.required(message: "This field is required")
    .minLength(8, message: "Must be at least 8 characters")

// Maximum length (automatically includes required check)
ValidationRule.maxLength(100, message: "Must be at most 100 characters")
```

#### Pattern Matching (Regex)
```swift
// Pattern matching (automatically includes required check)
ValidationRule.matches(#"^\d{4}-\d{2}-\d{2}$"#, message: "Must be in YYYY-MM-DD format")

// Or chain with required for custom message
.required(message: "This field is required")
    .matches(#"^\d{4}-\d{2}-\d{2}$"#, message: "Must be in YYYY-MM-DD format")
```

#### Password Requirements
```swift
.required(message: "Password is required")
    .minLength(8, message: "Password must be at least 8 characters")
    .containsUppercase(message: "Password must contain an uppercase letter")
    .containsLowercase(message: "Password must contain a lowercase letter")
    .containsNumber(message: "Password must contain a number")
    .containsSpecialCharacter(message: "Password must contain a special character")
```

#### Alphanumeric
```swift
.required(message: "This field is required")
    .alphanumeric(message: "Only letters and numbers are allowed")
```

### Integer Validations

`Validation<Int>` is available for validating integer values. You can use either `ValidationRule` namespace or `Validation<Int>` directly. Note that `ValidatedTextField` and `ValidatedSecureField` only accept `Validation<String>`, so you'll need to use `Validation<Int>` with custom fields or convert string input to integers.

```swift
// Using ValidationRule namespace (recommended)
let ageValidation = ValidationRule.min(18, message: "Must be at least 18")
let maxAgeValidation = ValidationRule.max(120, message: "Must be at most 120")
let scoreValidation = ValidationRule.range(1...100, message: "Must be between 1 and 100")

// Or using Validation<Int> directly
let ageValidation2 = Validation<Int>.min(18, message: "Must be at least 18")
let maxAgeValidation2 = Validation<Int>.max(120, message: "Must be at most 120")
let scoreValidation2 = Validation<Int>.range(1...100, message: "Must be between 1 and 100")

// Usage example with custom field
struct AgeInputView: View {
    @State private var ageText = ""
    @State private var errorMessage: String?
    
    private let validation = ValidationRule.range(1...120, message: "Age must be between 1 and 120")
    
    var body: some View {
        VStack(alignment: .leading) {
            TextField("Age", text: $ageText)
                .keyboardType(.numberPad)
                .onChange(of: ageText) { _, newValue in
                    if let age = Int(newValue) {
                        let result = validation.validate(age)
                        errorMessage = result.errorMessage
                    } else if !newValue.isEmpty {
                        errorMessage = "Please enter a valid number"
                    } else {
                        errorMessage = nil
                    }
                }
            
            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
}
```

### Custom Validation

```swift
ValidationRule.custom { value in
    value.count % 2 == 0 ? .valid : .invalid("Length must be even")
}
```

### Combining Validations

#### AND Logic
```swift
let validation = ValidationRule.required(message: "This field is required")
    .and(ValidationRule.email())
```

#### OR Logic
```swift
let validation = ValidationRule.email()
    .or(ValidationRule.phoneNumber())
```

#### Conditional Validation
```swift
let validation = ValidationRule.required(message: "Required")
    .when({ !$0.isEmpty }) { _ in
        ValidationRule.minLength(5, message: "Must be at least 5 characters")
    }
```

## Validation Modes

Control when validation occurs:

```swift
// Validate on every change (with debouncing)
ValidatedTextField(
    "Email",
    text: $email,
    validation: .email().required(),
    validationMode: .onChange
)

// Validate when field loses focus (default)
ValidatedTextField(
    "Email",
    text: $email,
    validation: .email().required(),
    validationMode: .onBlur
)

// Validate only on form submit
ValidatedTextField(
    "Email",
    text: $email,
    validation: .email().required(),
    validationMode: .onSubmit
)
```

## Error Message Positioning

Control where error messages appear:

```swift
// Below the field (default)
ValidatedTextField(
    "Email",
    text: $email,
    validation: .email().required(),
    errorPosition: .below
)

// Above the field
ValidatedTextField(
    "Email",
    text: $email,
    validation: .email().required(),
    errorPosition: .above
)

// Trailing side (right in LTR languages)
ValidatedTextField(
    "Email",
    text: $email,
    validation: .email().required(),
    errorPosition: .trailing
)
```

## Global Configuration

Configure default settings for all validated fields:

```swift
// Set default validation mode
FormValidationConfiguration.shared.defaultValidationMode = .onBlur

// Set default debounce interval (for onChange mode)
FormValidationConfiguration.shared.defaultDebounceInterval = 0.5

// Set default error position
FormValidationConfiguration.shared.errorMessagePosition = .below
```

## Form Validation State

Use `FormValidationState` to manage validation across multiple fields:

```swift
@State private var form = FormValidationState()

// Check if entire form is valid
if form.isValid {
    // Submit form
}

// Check specific field
if form.isValid(for: "email") {
    // Email is valid
}

// Get error for specific field
if let error = form.error(for: "email") {
    print("Email error: \(error)")
}

// Clear all errors
form.clearErrors()

// Clear error for specific field
form.clearError(for: "email")
```

## Advanced Usage

### Using Validation API Directly

You can use the validation API without `ValidatedTextField`:

```swift
let emailValidation = ValidationRule.email()
    .required(message: "Email is required")

let result = emailValidation.validate("test@example.com")
if result.isValid {
    print("Valid!")
} else {
    print("Error: \(result.errorMessage ?? "Unknown error")")
}
```

### Custom Text Field Integration

```swift
struct CustomValidatedField: View {
    @Binding var text: String
    @State private var errorMessage: String?
    
    private let validation = ValidationRule.email()
        .required(message: "Email is required")
    
    var body: some View {
        VStack(alignment: .leading) {
            TextField("Email", text: $text)
                .onChange(of: text) { _, newValue in
                    let result = validation.validate(newValue)
                    errorMessage = result.errorMessage
                }
            
            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
}
```

## Components

### ValidatedTextField

A text field with built-in validation capabilities.

**Parameters:**
- `title`: Placeholder text
- `text`: Binding to the text value
- `validation`: Validation rules to apply
- `form`: Optional form validation state binding
- `validationMode`: When to perform validation (default: from global config)
- `debounceInterval`: Debounce interval for onChange mode (default: 0.3 seconds)
- `errorPosition`: Where to display errors (default: `.below`)
- `keyboardType`: Keyboard type to display

### ValidatedSecureField

A secure text field (for passwords) with built-in validation and password visibility toggle.

**Parameters:**
- `title`: Placeholder text
- `text`: Binding to the text value
- `validation`: Validation rules to apply
- `form`: Optional form validation state binding
- `validationMode`: When to perform validation
- `debounceInterval`: Debounce interval for onChange mode
- `errorPosition`: Where to display errors

## Examples

Check out the `Samples` directory for complete examples:
- Email validation
- Password validation
- Confirm password validation
- ValidationRule API usage
- Integer validation (using ValidationRule namespace)

## License

See the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
