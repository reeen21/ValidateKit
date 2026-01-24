import SwiftUI
import ValidateKit

struct EmailValidationSample: View {
    @Binding var email: String
    @State private var isValid = false

    var body: some View {
        VStack {
            Text("Validation Result: \(isValid ? "Valid" : "Invalid")")

            ValidatedTextField(
                "Enter email",
                text: $email,
                validation:
                        .email()
                        .required(message: "Email is required")
                        .maxLength(20, message: "Enter no more than 20 characters"),
                onValidationChange: { valid, _ in
                    isValid = valid
                },
                errorPosition: .above
            )
        }
    }
}

#Preview {
    @Previewable @State var email: String = ""

    EmailValidationSample(email: $email)
        .padding()
}
