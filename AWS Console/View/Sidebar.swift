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
    @EnvironmentObject var userPreferences: UserPreferences
    @EnvironmentObject var s3Buckets: S3Buckets
    @EnvironmentObject var instances: EC2Instances
    
    var body: some View {
        List{
            //            Text("EC2")
            //                .font(.caption)
            //                .foregroundColor(.secondary)
            Section(header:Text("EC2")){
                NavigationLink(
                    destination: EC2View().environmentObject(instances).environmentObject(userPreferences),
                    tag: "Instances",
                    selection: $userPreferences.sidebarSelection,
                    label: {
                    Label("Instances", systemImage: "desktopcomputer")
                })
                //                NavigationLink(
                //                    destination: EC2View(),
                //                    isActive: $isDefaultItemActive,
                //                    label: {
                //                        Label("Instances", systemImage: "desktopcomputer")
                //                    })
//                NavigationLink(
//                    destination: Text("EBS"),
//                    tag: "EBS",
//                    selection: $userPreferences.sidebarSelection,
//                    label: {
//                    Label("EBS", systemImage: "externaldrive")
//                })
//                NavigationLink(
//                    destination: Text("AMIs"),
//                    tag: "AMIs",
//                    selection: $userPreferences.sidebarSelection,
//                    label: {
//                    Label("AMIs", systemImage: "photo")
//                })
                NavigationLink(
                    destination: InstanceTypesView(generalPurpose: instanceTypes.instanceTypes.filter({$0.starts(with: "a") || $0.starts(with: "m") || $0.starts(with: "t")}).sorted(), computeOptimized: instanceTypes.instanceTypes.filter({$0.starts(with: "c")}).sorted(), acceleratedCompute: instanceTypes.instanceTypes.filter({$0.starts(with: "f") || $0.starts(with: "g") || $0.starts(with: "i") || $0.starts(with: "p")}).sorted(), memoryOptimized: instanceTypes.instanceTypes.filter({$0.starts(with: "r") || $0.starts(with: "x") || $0.starts(with: "z")}).sorted(), storageOptimized: instanceTypes.instanceTypes.filter({$0.starts(with: "d") || $0.starts(with: "h") || $0.starts(with: "i")}).sorted()).environmentObject(instanceTypes).environmentObject(userPreferences),
                    tag: "Spot Pricing",
                    selection: $userPreferences.sidebarSelection,
                    label: {
                    Label("Spot Pricing", systemImage: "camera.metering.spot")
                })
            }
            //            Text("S3")
            //                .font(.caption)
            //                .foregroundColor(.secondary)
            Section(header:Text("S3")){
                NavigationLink(
                    destination: BucketsView().environmentObject(s3Buckets).environmentObject(userPreferences),
                    tag: "Buckets",
                    selection: $userPreferences.sidebarSelection,
                    label: {
                    Label("Buckets", systemImage: "tray")
                })
            }
            Spacer()
            NavigationLink(
                destination: SettingsView(),
                tag: "Settings",
                selection: $userPreferences.sidebarSelection,
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
