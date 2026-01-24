import SwiftUI
import ValidateKit

/// Sample demonstrating the onSubmit validation mode.
///
/// This sample shows how to use `.onSubmit` validation mode where validation
/// only occurs when the form is submitted, not during user input.
struct OnSubmitValidationSample: View {
    @State private var form = FormValidationState()
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isEmailValid = false
    @State private var isPasswordValid = false
    @State private var isConfirmPasswordValid = false
    @State private var emailError: String?
    @State private var passwordError: String?
    @State private var confirmPasswordError: String?
    
    private var isFormValid: Bool {
        form.isValid
    }
    
    var body: some View {
        Form {
            Section("Registration Form") {
                Text("Fill out the form and click Submit to validate all fields at once.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Section("Email") {
                ValidatedTextField(
                    "Email",
                    text: $email,
                    validation:
                            .email()
                            .required(message: "Email is required"),
                    fieldID: "email",
                    form: $form,
                    onValidationChange: { valid, errorMessage in
                        isEmailValid = valid
                        emailError = errorMessage
                    },
                    validationMode: .onSubmit
                )
            }
            
            Section("Password") {
                ValidatedSecureField(
                    "Password",
                    text: $password,
                    validation:
                        .required(message: "Password is required")
                        .minLength(8, message: "Password must be at least 8 characters")
                        .containsUppercase(message: "Password must contain an uppercase letter")
                        .containsNumber(message: "Password must contain a number"),
                    fieldID: "password",
                    form: $form,
                    onValidationChange: { valid, errorMessage in
                        isPasswordValid = valid
                        passwordError = errorMessage
                    },
                    validationMode: .onSubmit
                )
            }
            
            Section("Confirm Password") {
                ValidatedSecureField(
                    "Confirm Password",
                    text: $confirmPassword,
                    validation:
                        .required(message: "Confirm password is required")
                        .custom { confirm in
                            confirm == password ? .valid : .invalid("Passwords do not match")
                        },
                    fieldID: "confirmPassword",
                    form: $form,
                    onValidationChange: { valid, errorMessage in
                        isConfirmPasswordValid = valid
                        confirmPasswordError = errorMessage
                    },
                    validationMode: .onSubmit
                )
            }
            
            Section {
                Button("Submit") {
                    // Trigger validation for all fields with onSubmit mode
                    let isValid = form.validateAll()
                    if isValid {
                        // Form is valid, proceed with submission
                        print("Form submitted successfully!")
                    } else {
                        // Form has validation errors
                        print("Form has validation errors. Please fix them.")
                    }
                }
                .frame(maxWidth: .infinity)
                .disabled(!form.isValid)
            }
            
            Section("Form State") {
                HStack {
                    Text("Form Valid:")
                    Spacer()
                    Text("Validation Result: \(isFormValid ? "Valid" : "Invalid")")
                        .foregroundColor(isFormValid ? .green : .red)
                }
                
                // Using form.error(for:) with fieldID
                let formErrors = [
                    ("Email", form.error(for: "email")),
                    ("Password", form.error(for: "password")),
                    ("Confirm Password", form.error(for: "confirmPassword"))
                ].compactMap { field, error in
                    error.map { (field, $0) }
                }
                
                if !formErrors.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Errors (from FormValidationState):")
                            .font(.headline)
                        ForEach(formErrors, id: \.0) { field, error in
                            HStack {
                                Text("\(field):")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                
                // Also show individual field validity using form.isValid(for:)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Field Validity:")
                        .font(.headline)
                    HStack {
                        Text("Email:")
                            .font(.caption)
                            .fontWeight(.semibold)
                        Text(form.isValid(for: "email") ? "Valid" : "Invalid")
                            .font(.caption)
                            .foregroundColor(form.isValid(for: "email") ? .green : .red)
                    }
                    HStack {
                        Text("Password:")
                            .font(.caption)
                            .fontWeight(.semibold)
                        Text(form.isValid(for: "password") ? "Valid" : "Invalid")
                            .font(.caption)
                            .foregroundColor(form.isValid(for: "password") ? .green : .red)
                    }
                    HStack {
                        Text("Confirm Password:")
                            .font(.caption)
                            .fontWeight(.semibold)
                        Text(form.isValid(for: "confirmPassword") ? "Valid" : "Invalid")
                            .font(.caption)
                            .foregroundColor(form.isValid(for: "confirmPassword") ? .green : .red)
                    }
                }
            }
        }
        .navigationTitle("OnSubmit Validation")
    }
}

#Preview {
    NavigationStack {
        OnSubmitValidationSample()
    }
}
