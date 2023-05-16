//
//  ContentView.swift
//  ChattyIO
//
//  Created by Mike Schon on 5/14/23.
//

import SwiftUI

struct ContentView: View {
    @State private var userInput: String = ""
    @State private var gptOutput: String = ""
    @State private var isLoading = false
    let apiKey: String // Add this line to receive the API key as a parameter
    
    init(apiKey: String) {
        self.apiKey = apiKey // Add this line to initialize the API key
    }
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("ChattyIO - The ChatGPT Client!")
            TextField("Enter text here", text: $userInput, onCommit: {
                isLoading = true
                fetchTextFromChatGPT(prompt: userInput, apiKey: apiKey) { result in
                    isLoading = false
                    switch result {
                    case .success(let responseText):
                        print("Received response text: \(responseText)")
                        gptOutput = responseText
                    case .failure(let error):
                        print("Error: \(error)")
                        gptOutput = "Error: \(error)"
                    }
                }
            })
            .padding(.horizontal)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
            if isLoading {
                ProgressView()
            } else {
                Text("You entered: \(userInput)")
                Text("GPT output: \(gptOutput)")
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(apiKey: getAPIKey()) // Add this line to pass the API key as a parameter
    }
}
