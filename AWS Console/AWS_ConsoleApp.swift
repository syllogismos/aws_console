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
            PreferencesView()
                .environmentObject(userPreferences)
        }
        
        
    }
}

struct PreferencesView: View {
    @EnvironmentObject var userPreferences: UserPreferences
    private enum Tabs: Hashable {
        case keys, support, changelog
    }
    var body: some View {
        TabView {
            KeysView()
                .environmentObject(userPreferences)
                .tabItem {
                    Label("Keys", systemImage: "gear")
                }
                .tag(Tabs.keys)
            Support()
                .tabItem {
                    Label("Support", systemImage: "questionmark.circle")
                }
                .tag(Tabs.support)
            ChangeLog()
                .tabItem {
                    Label("Change Log", systemImage: "list.dash")
                }
                .tag(Tabs.changelog)
        }
        .padding(20)
        .frame(height: 200)
    }
}

// Hiding Textfiled focus ring
extension NSTextField{
    open override var focusRingType: NSFocusRingType{
        get{.none}
        set{}
    }
}
