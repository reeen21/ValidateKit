import SwiftUI
import ValidateKit

struct ConfirmPasswordValidationSample: View {
    @Binding var password: String
    @Binding var confirmPassword: String
    @State private var isPasswordValid = false
    @State private var isConfirmPasswordValid = false
    
    var body: some View {
        VStack {
            Text("Validation Result: \(isPasswordValid && isConfirmPasswordValid ? "Valid" : "Invalid")")
            ValidationSecureField(
                "Password",
                text: $password,
                validation:
                        .required(message: "Password is required")
                        .minLength(8, message: "Password must be at least 8 characters")
                        .containsUppercase(message: "Password must contain an uppercase letter")
                        .containsNumber(message: "Password must contain a number"),
                onValidationChange: { valid, _ in
                    isPasswordValid = valid
                }
            )
            
            ValidationSecureField(
                "Confirm Password",
                text: $confirmPassword,
                validation:
                        .required(message: "ConfirmPassword is required")
                        .custom { [password] confirm in
                            confirm == password ? .valid : .invalid("Passwords do not match")
                        },
                onValidationChange: { valid, _ in
                    isConfirmPasswordValid = valid
                }
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
