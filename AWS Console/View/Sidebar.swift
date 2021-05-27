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
            Text("EC2")
                .font(.caption)
                .foregroundColor(.secondary)
            NavigationLink(
                destination: EC2View(),
                isActive: $isDefaultItemActive,
                label: {
                    Label("Instances", systemImage: "desktopcomputer")
                })
            NavigationLink(
                destination: /*@START_MENU_TOKEN@*/Text("Destination")/*@END_MENU_TOKEN@*/,
                label: {
                    Label("EBS", systemImage: "externaldrive")
                })
            NavigationLink(
                destination: /*@START_MENU_TOKEN@*/Text("Destination")/*@END_MENU_TOKEN@*/,
                label: {
                    Label("AMIs", systemImage: "photo")
                })
            NavigationLink(
                destination: /*@START_MENU_TOKEN@*/Text("Destination")/*@END_MENU_TOKEN@*/,
                label: {
                    Label("Spot Pricing", systemImage: "camera.metering.spot")
                })
            Text("S3")
                .font(.caption)
                .foregroundColor(.secondary)
            NavigationLink(
                destination: Text("Destination"),
                label: {
                    Label("Buckets", systemImage: "tray")
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
