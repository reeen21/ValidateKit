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
                    form: $form,
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
                    form: $form,
                    validationMode: .onSubmit
                )
            }
            
            Section("Confirm Password") {
                ValidatedSecureField(
                    "Confirm Password",
                    text: $confirmPassword,
                    validation:
                        .required(message: "Confirm password is required")
                        .custom { [password] confirm in
                            confirm == password ? .valid : .invalid("Passwords do not match")
                        },
                    form: $form,
                    validationMode: .onSubmit
                )
            }
            
            Section {
                Button("Submit") {
                    if form.validateAll() {
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
                    Text("Validation Result: \(form.isValid ? "Valid" : "Invalid")")
                        .foregroundColor(form.isValid ? .green : .red)
                }
                
                if !form.errors.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Errors:")
                            .font(.headline)
                        ForEach(Array(form.errors.keys.sorted()), id: \.self) { field in
                            HStack {
                                Text("\(field):")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                Text(form.errors[field] ?? "")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
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
