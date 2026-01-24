import Foundation
import SwiftUI

/// Helper struct for common validation logic shared between `ValidationTextField` and `ValidationSecureField`.
@MainActor
struct ValidationFieldHelper {
    let fieldID: String
    let validation: Validation<String>
    let form: FormValidationState?
    let onValidationChange: ((Bool, String?) -> Void)?
    let validationMode: ValidationMode
    let debounceInterval: TimeInterval
    
    func validate(
        value: String,
        errorMessage: Binding<String?>
    ) {
        let result = validation.validate(value)
        
        switch result {
        case .valid:
            errorMessage.wrappedValue = nil
            form?.setValid(for: fieldID, isValid: true)
            onValidationChange?(true, nil)
        case .invalid(let message):
            errorMessage.wrappedValue = message
            form?.setError(for: fieldID, message: message)
            onValidationChange?(false, message)
        }
    }
    
    func handleTextChange(
        _ newValue: String,
        currentDebounceTask: Task<Void, Never>?,
        errorMessage: Binding<String?>
    ) -> Task<Void, Never>? {
        // Cancel any pending debounce task
        currentDebounceTask?.cancel()
        
        // For onSubmit mode, clear errors when user starts editing
        // This allows the submit button to be re-enabled after errors
        if validationMode == .onSubmit && errorMessage.wrappedValue != nil {
            errorMessage.wrappedValue = nil
            form?.clearError(for: fieldID)
            onValidationChange?(true, nil)
            return nil
        }
        
        guard validationMode == .onChange else { return nil }
        
        // Debounce validation to avoid excessive validation calls
        return Task {
            try? await Task.sleep(nanoseconds: UInt64(debounceInterval * 1_000_000_000))
            
            guard !Task.isCancelled else { return }
            
            await MainActor.run {
                validate(value: newValue, errorMessage: errorMessage)
            }
        }
    }
}
