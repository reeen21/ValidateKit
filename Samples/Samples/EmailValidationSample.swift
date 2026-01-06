import SwiftUI
import ValidateKit

struct EmailValidationSample: View {
    @Binding var email: String
    @State private var form = FormValidationState()

    var body: some View {
        VStack {
            Text("Validation Result: \(form.isValid.description)")

            ValidatedTextField(
                "Enter email",
                text: $email,
                validation:
                        .email()
                        .required(message: "Email is required")
                        .maxLength(20, message: "Enter no more than 20 characters"),
                form: $form,
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
