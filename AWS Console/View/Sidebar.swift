//
//  Sidebar.swift
//  AWS Console
//
//  Created by Anil Karaka on 25/05/2021.
//

import SwiftUI

struct Sidebar: View {
    
    @State private var isDefaultItemActive = true
    
    var body: some View {
        List{
            Text("Favorites")
                .font(.caption)
                .foregroundColor(.secondary)
            NavigationLink(
                destination: EC2View(),
                isActive: $isDefaultItemActive,
                label: {
                    Label("EC2", systemImage: "tray.2")
                })
            NavigationLink(
                destination: /*@START_MENU_TOKEN@*/Text("Destination")/*@END_MENU_TOKEN@*/,
                label: {
                    Label("EBS", systemImage: "paperplane")
                })
            Spacer()
            NavigationLink(
                destination: SettingsView(),
                label: {
                    Label("Settings", systemImage: "gear")
                })
        }
        .listStyle((SidebarListStyle()))
        .toolbar(content: {
            Button(action: toggleSidebar, label: {
                Image(systemName: "sidebar.left")
            })
        })
    }
}

struct Sidebar_Previews: PreviewProvider {
    static var previews: some View {
        Sidebar()
    }
}

private func toggleSidebar(){
    NSApp.keyWindow?.firstResponder?
        .tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
}
