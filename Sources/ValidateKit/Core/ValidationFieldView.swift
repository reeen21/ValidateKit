import SwiftUI

/// A reusable view component for validated text fields.
///
/// This component handles the common validation UI logic shared between
/// `ValidatedTextField` and `ValidatedSecureField`.
struct ValidationFieldView<Content: View>: View {
    @Binding var errorMessage: String?
    @FocusState.Binding var isFocused: Bool
    let title: String
    let validation: Validation<String>
    let form: Binding<FormValidationState>?
    @State private var internalForm: FormValidationState?
    let onValidationChange: ((Bool, String?) -> Void)?
    let validationMode: ValidationMode
    let debounceInterval: TimeInterval
    let errorPosition: ErrorPosition
    @Binding var debounceTask: Task<Void, Never>?
    let content: (Binding<String>) -> Content
    @Binding var text: String
    
    init(
        errorMessage: Binding<String?>,
        isFocused: FocusState<Bool>.Binding,
        title: String,
        validation: Validation<String>,
        form: Binding<FormValidationState>?,
        onValidationChange: ((Bool, String?) -> Void)?,
        validationMode: ValidationMode,
        debounceInterval: TimeInterval,
        errorPosition: ErrorPosition,
        debounceTask: Binding<Task<Void, Never>?>,
        content: @escaping (Binding<String>) -> Content,
        text: Binding<String>
    ) {
        self._errorMessage = errorMessage
        self._isFocused = isFocused
        self.title = title
        self.validation = validation
        self.form = form
        self.onValidationChange = onValidationChange
        self.validationMode = validationMode
        self.debounceInterval = debounceInterval
        self.errorPosition = errorPosition
        self._debounceTask = debounceTask
        self.content = content
        self._text = text
        self._internalForm = State(initialValue: form == nil ? FormValidationState() : nil)
    }
    
    private var formState: FormValidationState? {
        form?.wrappedValue ?? internalForm
    }
    
    private var helper: ValidationFieldHelper {
        ValidationFieldHelper(
            title: title,
            validation: validation,
            form: formState,
            onValidationChange: onValidationChange,
            validationMode: validationMode,
            debounceInterval: debounceInterval
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if errorPosition == .above {
                errorView
            }
            
            content($text)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(errorMessage != nil ? Color.red : Color.clear, lineWidth: 1)
                )
                .accessibilityLabel(title)
                .accessibilityValue(errorMessage ?? "")
                .focused($isFocused)
                .onChange(of: text) { _, newValue in
                    handleTextChange(newValue)
                }
                .onChange(of: isFocused) { _, focused in
                    if !focused && validationMode == .onBlur {
                        validate(value: text)
                    }
                }
            
            if errorPosition == .below || errorPosition == .trailing {
                HStack {
                    if errorPosition == .below {
                        errorView
                    } else {
                        Spacer()
                        errorView
                    }
                }
            }
        }
        .onAppear {
            if validationMode == .onChange {
                validate(value: text)
            }
            
            // Register validation function for onSubmit mode
            if validationMode == .onSubmit {
                // Capture the text binding to access the latest value when validation is triggered
                let textBinding = $text
                formState?.registerValidation(for: title) {
                    validate(value: textBinding.wrappedValue)
                }
            }
        }
        .onDisappear {
            debounceTask?.cancel()
            
            // Unregister validation function
            if validationMode == .onSubmit {
                formState?.unregisterValidation(for: title)
            }
        }
    }
    
    @ViewBuilder
    private var errorView: some View {
        if let errorMessage = errorMessage {
            Text(errorMessage)
                .font(.caption)
                .foregroundColor(.red)
                .accessibilityLabel("Error: \(errorMessage)")
        }
    }
    
    func handleTextChange(_ newValue: String) {
        debounceTask = helper.handleTextChange(newValue, currentDebounceTask: debounceTask, errorMessage: $errorMessage)
    }
    
    func validate(value: String) {
        helper.validate(value: value, errorMessage: $errorMessage)
    }
}
