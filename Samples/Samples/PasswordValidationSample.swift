import SwiftUI
import ValidateKit

struct PasswordValidationSample: View {
    @State private var form = FormValidationState()
    @Binding var password: String

    var body: some View {
            ValidatedTextField(
                "Password",
                text: $password,
                validation:
                        .required(message: "Password is required")
                        .minLength(8, message: "Password must be at least 8 characters")
                        .containsUppercase(message: "Password must contain an uppercase letter")
        )
    }
}

#Preview {
    @Previewable @State var password: String = ""
    PasswordValidationSample(password: $password)
        .padding()
}
