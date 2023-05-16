import Alamofire
import Foundation
import SwiftyJSON

func fetchTextFromChatGPT(prompt: String, apiKey: String, completionHandler: @escaping (Result<String, Error>) -> Void) {    
    let url = URL(string: "https://api.openai.com/v1/engines/text-davinci-003/completions")!
//    let url = URL(string: " https://api.openai.com/v1/chat/completions")!
    let parameters: [String: Any] = ["prompt": prompt, "max_tokens": 60]
    let headers = ["Content-Type": "application/json", "Authorization": "Bearer \(apiKey)"]

    AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers:HTTPHeaders(headers))
        .responseJSON { response in
            switch response.result {
            case .success(let value):
                if let json = value as? [String: Any], let text = json["choices"] as? [[String: Any]], let firstText = text.first, let result = firstText["text"] as? String {
                    completionHandler(.success(result))
                } else {
                    completionHandler(.failure(NSError(domain: "API Error", code: response.response?.statusCode ?? 500, userInfo: nil)))
                }
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

