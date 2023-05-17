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
    @State private var messages: [UIMessage] = []
    @State private var isLoading = false
    let apiKey: String // Add this line to receive the API key as a parameter
    let highlightr = Highlightr()
    
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
                    if message.role == "user" {
                        Text(message.content)
                            .id(message.id)
                            .padding(8)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    } else {
                        Text(message.content)
                            .id(message.id)
                            .padding(8)
                            .background(Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }.onChange(of: messages, perform: { _ in
                    scrollViewProxy.scrollTo(messages.last?.id, anchor: .bottom)
                })
            }
            
            TextField("Enter text here", text: $userInput, onCommit: {
                if !userInput.isEmpty {
                    isLoading = true
                    messages.append(UIMessage(content: userInput, role: "user"))
                    fetchTextFromChatGPT(prompt: userInput, apiKey: apiKey) { result in
                        isLoading = false
                        switch result {
                        case .success(let responseText):
                            messages.append(UIMessage(content: responseText, role: "assistant"))
                        case .failure(let error):
                            print("Error: \(error)")
                            messages.append(UIMessage(content: "Error: \(error)", role: "assistant"))
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

struct UIMessage: Identifiable, Equatable {
    let id = UUID()
    let content: String
    let role: String
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(apiKey: getAPIKey()) // Add this line to pass the API key as a parameter
    }
}

struct CodeTextView: View {
    let content: String
    let highlightr = Highlightr()

    var body: some View {
        if content.hasPrefix("```") && content.hasSuffix("```") {
            let codeContent = content.trimmingCharacters(in: .whitespacesAndNewlines).dropFirst(3).dropLast(3)
            let highlightedCode = highlightr?.highlight(String(codeContent), as: "python")
            
            if let codeString = highlightedCode?.value(forKey: "value") as? String {
                let attributedString = NSMutableAttributedString(string: codeString)
                
                return AnyView {
                    TextViewWrapper(attributedString: attributedString)
                        .foregroundColor(.white)
                        .background(Color.gray)
                        .cornerRadius(8)
                        .padding()
                }
            }
        }
        
        return AnyView {
            Text(content)
                .foregroundColor(.white)
                .background(Color.gray)
                .cornerRadius(8)
                .padding()
        }
    }
}

struct TextViewWrapper: NSViewRepresentable {
    let attributedString: NSAttributedString

    func makeNSView(context: Context) -> NSTextView {
        let textView = NSTextView()
        textView.isEditable = false
        textView.textContainerInset = NSSize(width: 8, height: 8)
        textView.textStorage?.setAttributedString(attributedString)
        return textView
    }

    func updateNSView(_ nsView: NSTextView, context: Context) {
        nsView.textStorage?.setAttributedString(attributedString)
    }
}
