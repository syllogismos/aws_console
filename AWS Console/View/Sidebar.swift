//
//  Sidebar.swift
//  AWS Console
//
//  Created by Anil Karaka on 25/05/2021.
//

import SwiftUI

struct Sidebar: View {
    
    @State private var isDefaultItemActive = true
    @EnvironmentObject var instanceTypes: InstanceTypes
    
    var body: some View {
        List{
            //            Text("EC2")
            //                .font(.caption)
            //                .foregroundColor(.secondary)
            Section(header:Text("EC2")){
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
                    destination: InstanceTypesView(generalPurpose: instanceTypes.instanceTypes.filter({$0.rawValue.starts(with: "a") || $0.rawValue.starts(with: "m") || $0.rawValue.starts(with: "t")}).map({$0.rawValue}).sorted(), computeOptimized: instanceTypes.instanceTypes.filter({$0.rawValue.starts(with: "c")}).map({$0.rawValue}).sorted(), acceleratedCompute: instanceTypes.instanceTypes.filter({$0.rawValue.starts(with: "f") || $0.rawValue.starts(with: "g") || $0.rawValue.starts(with: "i") || $0.rawValue.starts(with: "g")}).map({$0.rawValue}).sorted(), memoryOptimized: instanceTypes.instanceTypes.filter({$0.rawValue.starts(with: "r") || $0.rawValue.starts(with: "x") || $0.rawValue.starts(with: "z")}).map({$0.rawValue}).sorted(), storageOptimized: instanceTypes.instanceTypes.filter({$0.rawValue.starts(with: "d") || $0.rawValue.starts(with: "h") || $0.rawValue.starts(with: "i")}).map({$0.rawValue}).sorted()),
                    label: {
                        Label("Spot Pricing", systemImage: "camera.metering.spot")
                    })
            }
            //            Text("S3")
            //                .font(.caption)
            //                .foregroundColor(.secondary)
            Section(header:Text("S3")){
                NavigationLink(
                    destination: BucketsView(),
                    label: {
                        Label("Buckets", systemImage: "tray")
                    })
            }
            Spacer()
            //            NavigationLink(
            //                destination: SettingsView(),
            //                label: {
            //                    Label("Settings", systemImage: "gear")
            //                })
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
