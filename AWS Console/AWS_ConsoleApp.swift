//
//  AWS_ConsoleApp.swift
//  AWS Console
//
//  Created by Anil Karaka on 25/05/2021.
//

import SwiftUI

@main
struct AWS_ConsoleApp: App {
    @StateObject var userPreferences = UserPreferences()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userPreferences)
        }
        
        Settings{
            KeysView()
                .environmentObject(userPreferences)
        }
    }
}
