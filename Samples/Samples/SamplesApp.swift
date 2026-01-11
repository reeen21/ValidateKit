import SwiftUI

@main
struct SamplesApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                List {
                    NavigationLink("Email Validation Sample") {
                        EmailValidationSamplePreview()
                    }
                    
                    NavigationLink("Password Validation Sample") {
                        PasswordValidationSamplePreview()
                    }
                    
                    NavigationLink("Confirm Password Validation Sample") {
                        ConfirmPasswordValidationSamplePreview()
                    }
                    
                    NavigationLink("ValidationRule API Sample") {
                        ValidationRuleAPISamplePreview()
                    }
                    
                    NavigationLink("Int Validation Sample") {
                        IntValidationSamplePreview()
                    }
                }
                .navigationTitle("ValidateKit Samples")
            }
        }
    }
}

// MARK: - Preview Wrappers
struct EmailValidationSamplePreview: View {
    @State private var email: String = ""
    
    var body: some View {
        EmailValidationSample(email: $email)
            .padding()
    }
}

struct PasswordValidationSamplePreview: View {
    @State private var password: String = ""
    
    var body: some View {
        PasswordValidationSample(password: $password)
            .padding()
    }
}

struct ConfirmPasswordValidationSamplePreview: View {
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    
    var body: some View {
        ConfirmPasswordValidationSample(
            password: $password,
            confirmPassword: $confirmPassword
        )
        .padding()
    }
}

struct ValidationRuleAPISamplePreview: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    
    var body: some View {
        NavigationStack {
            ValidationRuleAPISample(
                email: $email,
                password: $password,
                confirmPassword: $confirmPassword
            )
        }
    }
}

struct IntValidationSamplePreview: View {
    var body: some View {
        NavigationStack {
            IntValidationSample()
        }
    }
}
