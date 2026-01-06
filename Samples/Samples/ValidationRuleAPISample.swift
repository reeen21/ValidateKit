import SwiftUI
import ValidateKit

/// Sample demonstrating how to use ValidationRule API directly without ValidatedTextField/ValidatedSecureField
struct ValidationRuleAPISample: View {
    @Binding var email: String
    @Binding var password: String
    @Binding var confirmPassword: String
    
    @State private var emailError: String?
    @State private var passwordError: String?
    @State private var confirmPasswordError: String?
    
    // Define validation rules using ValidationRule namespace
    private let emailValidation = ValidationRule.email()
        .required(message: "Email is required")
        .maxLength(100, message: "Email must be at most 100 characters")
    
    private let passwordValidation = ValidationRule.required(message: "Password is required")
        .minLength(8, message: "Password must be at least 8 characters")
        .containsUppercase(message: "Password must contain an uppercase letter")
        .containsNumber(message: "Password must contain a number")
    
    private var confirmPasswordValidation: Validation<String> {
        ValidationRule.required(message: "Confirm password is required")
            .custom { [password] confirm in
                confirm == password ? .valid : .invalid("Passwords do not match")
            }
    }
    
    var body: some View {
        Form {
            Section("Email Validation") {
                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: email) { _, newValue in
                        validateEmail(newValue)
                    }
                
                if let error = emailError {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            
            Section("Password Validation") {
                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: password) { _, newValue in
                        validatePassword(newValue)
                    }
                
                if let error = passwordError {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            
            Section("Confirm Password Validation") {
                SecureField("Confirm Password", text: $confirmPassword)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: confirmPassword) { _, newValue in
                        validateConfirmPassword(newValue)
                    }
                
                if let error = confirmPasswordError {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            
            Section {
                Button("Submit") {
                    validateAll()
                }
                .disabled(!isFormValid)
            }
        }
        .navigationTitle("ValidationRule API Sample")
    }
    
    private var isFormValid: Bool {
        emailError == nil && passwordError == nil && confirmPasswordError == nil &&
        !email.isEmpty && !password.isEmpty && !confirmPassword.isEmpty
    }
    
    private func validateEmail(_ value: String) {
        let result = emailValidation.validate(value)
        emailError = result.errorMessage
    }
    
    private func validatePassword(_ value: String) {
        let result = passwordValidation.validate(value)
        passwordError = result.errorMessage
    }
    
    private func validateConfirmPassword(_ value: String) {
        let result = confirmPasswordValidation.validate(value)
        confirmPasswordError = result.errorMessage
    }
    
    private func validateAll() {
        validateEmail(email)
        validatePassword(password)
        validateConfirmPassword(confirmPassword)
    }
}

#Preview {
    @Previewable @State var email: String = ""
    @Previewable @State var password: String = ""
    @Previewable @State var confirmPassword: String = ""
    
    NavigationStack {
        ValidationRuleAPISample(
            email: $email,
            password: $password,
            confirmPassword: $confirmPassword
        )
        .padding()
    }
}
