//
//  ChattyIOApp.swift
//  ChattyIO
//
//  Created by Mike Schon on 5/14/23.
//

import SwiftUI

@main
struct ChattyIOApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(apiKey: getAPIKey())
        }
    }
}
