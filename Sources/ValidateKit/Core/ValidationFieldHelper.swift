import Foundation
import SwiftUI

/// Helper struct for common validation logic shared between `ValidatedTextField` and `ValidatedSecureField`.
@MainActor
struct ValidationFieldHelper {
    let title: String
    let validation: Validation<String>
    let form: Binding<FormValidationState>?
    let validationMode: ValidationMode
    let debounceInterval: TimeInterval
    
    func validate(
        newValue: String,
        errorMessage: Binding<String?>
    ) {
        let result = validation.validate(newValue)
        
        switch result {
        case .valid:
            errorMessage.wrappedValue = nil
            form?.wrappedValue.setValid(for: title, isValid: true)
        case .invalid(let message):
            errorMessage.wrappedValue = message
            form?.wrappedValue.setError(for: title, message: message)
        }
    }
    
    func handleTextChange(
        _ newValue: String,
        currentDebounceTask: Task<Void, Never>?,
        errorMessage: Binding<String?>
    ) -> Task<Void, Never>? {
        // Cancel any pending debounce task
        currentDebounceTask?.cancel()
        
        guard validationMode == .onChange else { return nil }
        
        // Debounce validation to avoid excessive validation calls
        return Task {
            try? await Task.sleep(nanoseconds: UInt64(debounceInterval * 1_000_000_000))
            
            guard !Task.isCancelled else { return }
            
            await MainActor.run {
                validate(newValue: newValue, errorMessage: errorMessage)
            }
        }
    }
}

