import SwiftUI

struct SettingsView: View {
    @AppStorage("apiKey") private var apiKey: String = ""
    @State private var inputApiKey: String = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Form {
            Section(header: Text("API Key")) {
                TextField("Enter your API key", text: $inputApiKey)
                    .textContentType(.oneTimeCode)
                    .frame(maxWidth: .infinity)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            HStack {
                Button("Save") {
                    saveApiKey()
                    presentationMode.wrappedValue.dismiss()
                }
                .buttonStyle(.bordered)
                
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.red)
                .buttonStyle(.bordered)
            }
            .padding(.top, 10)
        }
        .frame(minWidth: 400, maxWidth: .infinity) // Set a minimum and maximum width for the settings view
        .onAppear {
            inputApiKey = apiKey
        }
    }
    
    private func saveApiKey() {
        apiKey = inputApiKey
    }
}
