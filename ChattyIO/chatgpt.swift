import Alamofire
import Foundation
import SwiftyJSON

struct ChatGPTResponse: Decodable {
    let choices: [Choice]
}

struct Choice: Decodable {
    let message: Message
//    let text: String
}

struct Message: Decodable {
    let content: String
}

func fetchTextFromChatGPT(messages: [UIMessage], apiKey: String, completionHandler: @escaping (Result<String, Error>) -> Void) {
    let url = URL(string: "https://api.openai.com/v1/chat/completions")!
    let messageParams = messages.map { ["role": $0.role, "content": $0.content] }
    let parameters: [String: Any] = [
        "model": "gpt-3.5-turbo",
        "messages": messageParams,
        "max_tokens": 1000
    ]
    let headers: HTTPHeaders = [
        "Content-Type": "application/json",
        "Authorization": "Bearer \(apiKey)"
    ]

    AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
        .validate()
        .responseDecodable(of: ChatGPTResponse.self) { response in
            switch response.result {
            case .success(let chatGPTResponse):
                guard let content = chatGPTResponse.choices.first?.message.content else {
                    completionHandler(.failure(NSError(domain: "API Error", code: 500, userInfo: nil)))
                    return
                }
                completionHandler(.success(content))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
}



func getAPIKey() -> String {
    guard let path = Bundle.main.path(forResource: "config", ofType: "plist"),
          let xml = FileManager.default.contents(atPath: path),
          let config = try? PropertyListSerialization.propertyList(from: xml, options: .mutableContainersAndLeaves, format: nil) as? [String: Any],
          let apiKey = config["apiKey"] as? String else {
        fatalError("Failed to read API key from config.plist")
    }
    return apiKey
}

