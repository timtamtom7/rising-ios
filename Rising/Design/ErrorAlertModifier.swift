import SwiftUI

struct ErrorAlertModifier: ViewModifier {
    @Binding var errorMessage: String?
    var onRetry: (() -> Void)?

    func body(content: Content) -> some View {
        content
            .alert("Error", isPresented: .init(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK") { errorMessage = nil }
                if let onRetry {
                    Button("Retry") {
                        errorMessage = nil
                        onRetry()
                    }
                }
            } message: {
                Text(errorMessage ?? "")
            }
    }
}

extension View {
    func errorAlert(errorMessage: Binding<String?>, onRetry: (() -> Void)? = nil) -> some View {
        modifier(ErrorAlertModifier(errorMessage: errorMessage, onRetry: onRetry))
    }
}