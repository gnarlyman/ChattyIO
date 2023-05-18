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
    @State private var showSettings = false
    @AppStorage("apiKey") private var apiKey: String = ""

    @FocusState private var isTextFieldFocused: Bool

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
                        }
                    }
                }
            }

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
        case .assistant:
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray)
                VStack(alignment: .leading) {
                    SyntaxHighlightTextView(content: message.content)
                        .foregroundColor(.white)
                        .padding(8)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        case .system:
            Text(message.content)
                .padding(8)
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(8)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}






struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct SyntaxHighlightTextView: View {
    let content: String
    let highlightr = Highlightr()
    
    var body: some View {
        let codeRanges = findCodeRanges(content)
        let attributedString = NSMutableAttributedString(string: content)
        
        for (codeRange, language) in codeRanges {
            let codeContent = String(content[Range(codeRange, in: content)!])
            
            if let highlightedCode = highlightr?.highlight(codeContent, as: language) {
                attributedString.replaceCharacters(in: codeRange, with: highlightedCode)
            }
        }
        
        return ZStack {
            Color.clear // Set the desired background color
            
            TextViewWrapper(attributedString: attributedString, textColor: .white, backgroundColor: .clear)
                .foregroundColor(.white)
        }
    }
    
    private func findCodeRanges(_ content: String) -> [(NSRange, String)] {
        var ranges: [(NSRange, String)] = []
        
        let pattern = #"\`\`\`([a-zA-Z0-9_]+)?(.*?)\`\`\`"#
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let matches = regex?.matches(in: content, options: [], range: NSRange(location: 0, length: content.utf16.count))
        
        for match in matches ?? [] {
            if match.numberOfRanges >= 3 {
                let languageRange = match.range(at: 1)
                let codeRange = match.range(at: 2)
                
                if let languageRange = Range(languageRange, in: content),
                   let codeRange = Range(codeRange, in: content) {
                    let language = content[languageRange].trimmingCharacters(in: .whitespacesAndNewlines)
                    ranges.append((NSRange(codeRange, in: content), language))
                }
            }
        }
        
        return ranges
    }
}

struct TextViewWrapper: NSViewRepresentable {
    let attributedString: NSAttributedString
    let textColor: NSColor
    let backgroundColor: NSColor

    func makeNSView(context: Context) -> NSTextView {
        let textView = NSTextView()
        textView.isEditable = false
        textView.isSelectable = false
        textView.textContainerInset = NSSize(width: 8, height: 8)
        textView.backgroundColor = backgroundColor
        textView.textColor = textColor
        textView.textStorage?.setAttributedString(attributedString)
        return textView
    }

    func updateNSView(_ nsView: NSTextView, context: Context) {
        nsView.textStorage?.setAttributedString(attributedString)
        nsView.textColor = textColor
        nsView.backgroundColor = backgroundColor
    }
}
