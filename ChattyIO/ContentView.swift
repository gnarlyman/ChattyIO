//
//  ContentView.swift
//  ChattyIO
//
//  Created by Mike Schon on 5/14/23.
//

import SwiftUI

struct UIMessage: Identifiable, Equatable {
    let id = UUID()
    var text: String
    var isUser: Bool
}

struct ContentView: View {
    @State private var userInput: String = ""
    @State private var messages: [UIMessage] = []
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
            
            ScrollViewReader { scrollViewProxy in
                List(messages, id: \.id) { message in
                    Text(message.text)
                        .id(message.id)
                        .padding(8)
                        .background(message.isUser ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }.onChange(of: messages, perform: { _ in
                    scrollViewProxy.scrollTo(messages.last?.id, anchor: .bottom)
                })
            }
            
            TextField("Enter text here", text: $userInput, onCommit: {
                if !userInput.isEmpty {
                    isLoading = true
                    messages.append(UIMessage(text: userInput, isUser: true))
                    fetchTextFromChatGPT(prompt: userInput, apiKey: apiKey) { result in
                        isLoading = false
                        switch result {
                        case .success(let responseText):
                            print("Received response text: \(responseText)")
                            messages.append(UIMessage(text: responseText, isUser: false))
                        case .failure(let error):
                            print("Error: \(error)")
                            messages.append(UIMessage(text: "Error: \(error)", isUser: false))
                        }
                    }
                }
                userInput = ""
            })
            .padding(.horizontal)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
            if isLoading {
                ProgressView()
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
