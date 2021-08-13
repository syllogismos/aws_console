//
//  ContentView.swift
//  AWS Console
//
//  Created by Anil Karaka on 25/05/2021.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var instances = EC2Instances()
    @StateObject var s3Buckets = S3Buckets()
    @StateObject var spotPrice = SpotPrice()
    @StateObject var instanceTypes = InstanceTypes()
    @StateObject var amiViewModel = AMIViewModel()
    @EnvironmentObject var userPreferences: UserPreferences
    let timer = Timer.publish(every: 300, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationView{
            Sidebar()
            Text("No Sidebar Selection")
            if userPreferences.sidebarSelection == "Instances" {
            Text("Select an instance")
            } else if userPreferences.sidebarSelection == "Buckets" {
                Text("Select a Bucket")
            } else if userPreferences.sidebarSelection == "Spot Pricing" {
                Text("Select an Instance Type to get pricing details")
//            } else if userPreferences.sidebarSelection == "Settings" {
//                Text("None").frame(width: 0)
            }        }
        .environmentObject(instances)
//        .environmentObject(userPreferences)
        .environmentObject(s3Buckets)
        .environmentObject(spotPrice)
        .environmentObject(instanceTypes)
//        .environmentObject(amiViewModel)
        // Refresh instances automatically every 300 seconds.
        .onReceive(timer, perform:{time in self.instances.getEC2Instances()})
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
