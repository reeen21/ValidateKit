import SwiftUI
import ValidateKit

struct ConfirmPasswordValidationSample: View {
    @State private var form = FormValidationState()
    @Binding var password: String
    @Binding var confirmPassword: String
    
    var body: some View {
        VStack {
            Text("Validation Result: \(form.isValid ? "Valid" : "Invalid")")
            ValidatedSecureField(
                "Password",
                text: $password,
                validation:
                        .required(message: "Password is required")
                        .minLength(8, message: "Password must be at least 8 characters")
                        .containsUppercase(message: "Password must contain an uppercase letter")
                        .containsNumber(message: "Password must contain a number"),
                form: $form
            )
            
            ValidatedSecureField(
                "Confirm Password",
                text: $confirmPassword,
                validation:
                        .required(message: "ConfirmPassword is required")
                        .custom { [password] confirm in
                            confirm == password ? .valid : .invalid("Passwords do not match")
                        },
                form: $form
            )
        }
    }
}

#Preview {
    @Previewable @State var password: String = ""
    @Previewable @State var confirmPassword: String = ""

    ConfirmPasswordValidationSample(password: $password, confirmPassword: $confirmPassword)
        .padding()
}
