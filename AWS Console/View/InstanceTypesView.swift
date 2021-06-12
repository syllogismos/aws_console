//
//  InstanceTypesView.swift
//  AWS Console
//
//  Created by Anil Karaka on 29/05/2021.
//

import SwiftUI

struct InstanceTypesView: View {
    @EnvironmentObject var instanceTypes: InstanceTypes
    @EnvironmentObject var userPreferences: UserPreferences
    @State private var isLoading = false
    var generalPurpose: [String]
    var computeOptimized: [String]
    var acceleratedCompute: [String]
    var memoryOptimized: [String]
    var storageOptimized: [String]
    var body: some View {
        VStack {
            
            List{
                if generalPurpose.count > 0 {
                    Section(header: Text("General Purpose").foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)) {
                        ForEach(instanceTypes.searchString.isEmpty ? generalPurpose : generalPurpose.filter({$0.contains(instanceTypes.searchString)}), id: \.self){type in
//                            Text(type)
                            NavigationLink(destination: InstanceTypeView(type: type), label: {Text(type)})
                        }
                    }
                }
                if computeOptimized.count > 0 {
                    Section(header: Text("Compute Optimized").foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)) {
                        ForEach(instanceTypes.searchString.isEmpty ? computeOptimized : computeOptimized.filter({$0.contains(instanceTypes.searchString)}) , id: \.self){type in
//                            Text(type)
                            NavigationLink(destination: InstanceTypeView(type: type), label: {Text(type)})
                        }
                    }
                }
                if acceleratedCompute.count > 0 {
                    Section(header: Text("Accelerated Compute").foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)) {
                        ForEach(instanceTypes.searchString.isEmpty ? acceleratedCompute : acceleratedCompute.filter({$0.contains(instanceTypes.searchString)}), id: \.self){type in
//                            Text(type)
                            NavigationLink(destination: InstanceTypeView(type: type), label: {Text(type)})
                        }
                    }
                }
                if memoryOptimized.count > 0 {
                    Section(header: Text("Memory Optimized").foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)) {
                        ForEach(instanceTypes.searchString.isEmpty ? memoryOptimized : memoryOptimized.filter({$0.contains(instanceTypes.searchString)}), id: \.self){type in
//                            Text(type)
                            NavigationLink(destination: InstanceTypeView(type: type), label: {Text(type)})
                        }
                    }
                }
                if storageOptimized.count > 0 {
                    Section(header: Text("Storage Optimized").foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)) {
                        ForEach(instanceTypes.searchString.isEmpty ? storageOptimized : storageOptimized.filter({$0.contains(instanceTypes.searchString)}), id: \.self){type in
//                            Text(type)
                            NavigationLink(destination: InstanceTypeView(type: type), label: {Text(type)})
                        }
                    }
                }
            }
//            List{
//                ForEach(instanceTypes.instanceTypes, id: \.self){type in
//                    NavigationLink(destination: InstanceTypeView(type: type), label: {Text(type)})
//                }
//
//            }
        }
        .navigationTitle("Instance Types")
        .toolbar {
            HStack {
//                Image(systemName: "magnifyingglass")
//                    .foregroundColor(.gray)
                TextField("Search...", text: $instanceTypes.searchString)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(minWidth: 180)
                //                    .textFieldStyle(PlainTextFieldStyle())
            }
            Picker(selection: $userPreferences.os, label: Text("Operating System")){ForEach(OSList, id: \.pricingAttributeName){os in Text(os.name).tag(os)}
            }
            Picker(selection: $userPreferences.region, label: Text("Region")) {ForEach(regions, id: \.self){region in Text(region)}}
                .onChange(of: userPreferences.region, perform: {_ in
                    instanceTypes.getInstanceOfferings()
                })
//            Image(systemName: "arrow.clockwise")
//                .rotationEffect(Angle(degrees: isLoading ? 360 : 0))
//                .animation(Animation.default.repeatForever(autoreverses: false))
//                .onAppear() {
//                    self.isLoading = false
//                }
            
        }
    }
}

struct InstanceTypesView_Previews: PreviewProvider {
    static var previews: some View {
        InstanceTypesView(generalPurpose: ["anil"], computeOptimized: ["anil"], acceleratedCompute: ["anil"], memoryOptimized: ["anil"], storageOptimized: ["anil"]).environmentObject(InstanceTypes())
    }
}


// General Purpose a, m, t
// Compute Optimized c
// Accelerated Computing f, g, i, p
// Memory Optimized r, x, z
// Storage Optimized d, h, i
