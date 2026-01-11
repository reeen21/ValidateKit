import SwiftUI
import ValidateKit

struct IntValidationSample: View {
    @State private var ageText = ""
    @State private var scoreText = ""
    @State private var quantityText = ""
    
    @State private var ageErrorMessage: String?
    @State private var scoreErrorMessage: String?
    @State private var quantityErrorMessage: String?
    
    // Age validation: must be between 1 and 120
    private let ageValidation = ValidationRule.range(1...120, message: "Age must be between 1 and 120")
    
    // Score validation: must be between 0 and 100
    private let scoreValidation = ValidationRule.range(0...100, message: "Score must be between 0 and 100")
    
    // Quantity validation: must be at least 1
    private let quantityValidation = ValidationRule.min(1, message: "Quantity must be at least 1")
    
    var body: some View {
        Form {
            Section("Age Input (1-120)") {
                VStack(alignment: .leading, spacing: 4) {
                    TextField("Age", text: $ageText)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(ageErrorMessage != nil ? Color.red : Color.clear, lineWidth: 1)
                        )
                        .onChange(of: ageText) { _, newValue in
                            validateAge(newValue)
                        }
                    
                    if let error = ageErrorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
            
            Section("Score Input (0-100)") {
                VStack(alignment: .leading, spacing: 4) {
                    TextField("Score", text: $scoreText)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(scoreErrorMessage != nil ? Color.red : Color.clear, lineWidth: 1)
                        )
                        .onChange(of: scoreText) { _, newValue in
                            validateScore(newValue)
                        }
                    
                    if let error = scoreErrorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
            
            Section("Quantity Input (minimum 1)") {
                VStack(alignment: .leading, spacing: 4) {
                    TextField("Quantity", text: $quantityText)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(quantityErrorMessage != nil ? Color.red : Color.clear, lineWidth: 1)
                        )
                        .onChange(of: quantityText) { _, newValue in
                            validateQuantity(newValue)
                        }
                    
                    if let error = quantityErrorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .navigationTitle("Int Validation Sample")
    }
    
    private func validateAge(_ text: String) {
        if let age = Int(text) {
            let result = ageValidation.validate(age)
            ageErrorMessage = result.errorMessage
        } else if !text.isEmpty {
            ageErrorMessage = "Please enter a valid number"
        } else {
            ageErrorMessage = nil
        }
    }
    
    private func validateScore(_ text: String) {
        if let score = Int(text) {
            let result = scoreValidation.validate(score)
            scoreErrorMessage = result.errorMessage
        } else if !text.isEmpty {
            scoreErrorMessage = "Please enter a valid number"
        } else {
            scoreErrorMessage = nil
        }
    }
    
    private func validateQuantity(_ text: String) {
        if let quantity = Int(text) {
            let result = quantityValidation.validate(quantity)
            quantityErrorMessage = result.errorMessage
        } else if !text.isEmpty {
            quantityErrorMessage = "Please enter a valid number"
        } else {
            quantityErrorMessage = nil
        }
    }
}

#Preview {
    NavigationStack {
        IntValidationSample()
    }
}

