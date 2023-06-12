//
//  ContentView.swift
//  ChattyIO
//
//  Created by Mike Schon on 5/14/23.
//

import SwiftUI
import Highlightr
import AppKit

struct ContentView: View {
    @State private var userInput: String = ""
    @State private var messages: [UIMessage]
    @State private var isLoading = false
    @State private var showSettings = false
    @AppStorage("apiKey") private var apiKey: String = ""

    @FocusState private var isTextFieldFocused: Bool

    init(messages: [UIMessage]) {
        self._messages = State(initialValue: messages)
    }

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("ChattyIO - The ChatGPT Client!")
            Button(action: {
                showSettings = true
            }) {
                Text("Settings")
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }

            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(messages) { message in
                            MessageView(message: message)
                                .id(message.id) // Use the message ID as the identifier
                        }
                    }
                    .padding(16) // Add padding to the LazyVStack
                    .onChange(of: messages) { _ in
                        // Scroll to the bottom when messages change
                        withAnimation {
                            scrollViewProxy.scrollTo(messages.last?.id, anchor: .bottom)
                        }
                    }
                }
            }

            HStack {
                TextField("Enter text here", text: $userInput)
                    .padding(.horizontal)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .focused($isTextFieldFocused)
                    .submitLabel(.done)
                    .onSubmit {
                        if !userInput.isEmpty {
                            isLoading = true
                            let userMessage = UIMessage(content: userInput, role: Role.user)
                            messages.append(userMessage)
                            fetchTextFromChatGPT(messages: messages, apiKey: apiKey) { result in
                                switch result {
                                case .success(let content):
                                    let assistantMessage = UIMessage(content: content, role: Role.assistant)
                                    messages.append(assistantMessage)
                                case .failure(let error):
                                    print("Error: \(error)")
                                    let errorMessage = UIMessage(content: "Error: \(error)", role: Role.assistant)
                                    messages.append(errorMessage)
                                }

                                isLoading = false
                            }

                            userInput = ""
                        }
                    }

                if isLoading {
                    ProgressView()
                        .padding(.leading)
                }
            }
        }
        .padding()
    }
}


enum Role: String {
    case user = "user"
    case assistant = "assistant"
    case system = "system"
}

struct UIMessage: Identifiable, Equatable {
    let id = UUID()
    let content: String
    let role: Role
}

// API functions and models here...

struct MessageView: View {
    let message: UIMessage

    var body: some View {
        switch message.role {
        case .user:
            Text(message.content)
                .padding(8)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 16) // Add leading padding for user messages
                .padding(.trailing, 80) // Add trailing padding for user messages
                .alignmentGuide(.trailing) { _ in CGFloat.infinity } // Align user messages to the left
        case .assistant, .system:
            Text(message.content)
                .padding(8)
                .background(Color.gray)
                .foregroundColor(.white)
                .cornerRadius(8)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.leading, 80) // Add leading padding for assistant/system messages
                .padding(.trailing, 16) // Add trailing padding for assistant/system messages
                .alignmentGuide(.leading) { _ in CGFloat.infinity } // Align assistant/system messages to the right
        }
    }
}




// Fake messages for preview
let fakeMessages: [UIMessage] = [
    UIMessage(content: "Hello!", role: .user),
    UIMessage(content: "Hi there!", role: .assistant),
    UIMessage(content: "How are you?", role: .user),
    UIMessage(content: "I'm doing well, thanks!", role: .assistant),
    UIMessage(content: "That's great to hear!", role: .user),
    UIMessage(content: "Yes, it definitely is.", role: .assistant),
    UIMessage(content: "By the way, have you seen the latest movie?", role: .assistant),
    UIMessage(content: "No, I haven't. Is it good?", role: .user),
    UIMessage(content: "Absolutely! It's a must-watch.", role: .assistant)
]

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(messages: fakeMessages)
    }
}
