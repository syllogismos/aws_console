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
    let timer = Timer.publish(every: 300, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationView{
            Sidebar()
            Text("No Sidebar Selection")
            Text("No Message Selection")
        }
        .environmentObject(instances)
//        .environmentObject(userPreferences)
        .environmentObject(s3Buckets)
        .environmentObject(spotPrice)
        .environmentObject(instanceTypes)
        // Refresh instances automatically every 300 seconds.
        .onReceive(timer, perform:{time in self.instances.getEC2Instances()})
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
