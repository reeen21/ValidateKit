import SwiftUI
import ValidateKit

/// Sample demonstrating the use of fieldID parameter.
///
/// This sample shows how to use `fieldID` to uniquely identify fields in `FormValidationState`,
/// which is especially useful when multiple fields have the same placeholder text or when
/// you want to programmatically access field errors and validation states.
struct FieldIDSample: View {
    @State private var form = FormValidationState()
    @State private var primaryEmail: String = ""
    @State private var secondaryEmail: String = ""
    
    var body: some View {
        Form {
            Section("Why Use fieldID?") {
                Text("When multiple fields have the same placeholder text, or when you want to programmatically access field errors, use `fieldID` to uniquely identify each field.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Section("Primary Email") {
                ValidatedTextField(
                    "Enter your email",  // Same placeholder text
                    text: $primaryEmail,
                    validation: .email().required(message: "Primary email is required"),
                    fieldID: "primaryEmail",  // Unique identifier
                    form: $form,
                    validationMode: .onBlur
                )
            }
            
            Section("Secondary Email") {
                ValidatedTextField(
                    "Enter your email",  // Same placeholder text
                    text: $secondaryEmail,
                    validation: .email().required(message: "Secondary email is required"),
                    fieldID: "secondaryEmail",  // Unique identifier
                    form: $form,
                    validationMode: .onBlur
                )
            }
            
            Section("Access Errors Using fieldID") {
                // Access errors using fieldID
                if let primaryError = form.error(for: "primaryEmail") {
                    HStack {
                        Text("Primary Email Error:")
                            .font(.caption)
                            .fontWeight(.semibold)
                        Text(primaryError)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                if let secondaryError = form.error(for: "secondaryEmail") {
                    HStack {
                        Text("Secondary Email Error:")
                            .font(.caption)
                            .fontWeight(.semibold)
                        Text(secondaryError)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                if form.error(for: "primaryEmail") == nil && form.error(for: "secondaryEmail") == nil {
                    Text("No errors")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
            
            Section("Check Field Validity Using fieldID") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Primary Email:")
                            .font(.caption)
                            .fontWeight(.semibold)
                        Spacer()
                        Text(form.isValid(for: "primaryEmail") ? "✓ Valid" : "✗ Invalid")
                            .font(.caption)
                            .foregroundColor(form.isValid(for: "primaryEmail") ? .green : .red)
                    }
                    
                    HStack {
                        Text("Secondary Email:")
                            .font(.caption)
                            .fontWeight(.semibold)
                        Spacer()
                        Text(form.isValid(for: "secondaryEmail") ? "✓ Valid" : "✗ Invalid")
                            .font(.caption)
                            .foregroundColor(form.isValid(for: "secondaryEmail") ? .green : .red)
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Form Valid:")
                            .font(.caption)
                            .fontWeight(.semibold)
                        Spacer()
                        Text(form.isValid ? "✓ All fields valid" : "✗ Some fields invalid")
                            .font(.caption)
                            .foregroundColor(form.isValid ? .green : .red)
                    }
                }
            }
            
            Section {
                Button("Clear All Errors") {
                    form.clearErrors()
                }
                .frame(maxWidth: .infinity)
                
                Button("Clear Primary Email Error") {
                    form.clearError(for: "primaryEmail")
                }
                .frame(maxWidth: .infinity)
                
                Button("Clear Secondary Email Error") {
                    form.clearError(for: "secondaryEmail")
                }
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle("Field ID Sample")
    }
}

#Preview {
    NavigationStack {
        FieldIDSample()
    }
}
