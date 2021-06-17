//
//  EC2View.swift
//  AWS Console
//
//  Created by Anil Karaka on 25/05/2021.
//

import SwiftUI
import SotoEC2

struct EC2View: View {
    
    @EnvironmentObject var instances: EC2Instances
    @EnvironmentObject var userPreferences: UserPreferences
    
    @State var instanceName = ""
    
    
    var body: some View {
        VStack(spacing: 0.0) {
            List(instances.searchString == "" ? self.instances.instances : self.instances.instances.filter({self.instances.searchInstanceString(i: $0, searchString: self.instances.searchString)}), id: \.instanceId){ instance in
                NavigationLink(
                    destination: InstanceView(instance: instance),
                    label: {
                        Text(instance.instanceId ?? "")
                    })
            }
            .navigationTitle("EC2 Instances")
            .toolbar{
                TextField("Search...", text: $instances.searchString)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(minWidth: 180)
                Picker(selection: $userPreferences.region, label: Text("Region")) {ForEach(regions, id: \.self){region in Text(region)}}
                    .onChange(of: userPreferences.region, perform: {_ in
                        instances.getEC2Instances()
                    })
                Button(action: {instances.getEC2Instances()}){
                    Image(systemName: "arrow.clockwise")
                }
            }
            HStack(spacing: 2.0) {
                TextField("Create New Instance", text: $instanceName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: {}){
                    Image(systemName: "plus")
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(6.0)
        }
    }
}

struct EC2View_Previews: PreviewProvider {
    static var previews: some View {
        EC2View()
            .environmentObject(EC2Instances())
            .environmentObject(UserPreferences())
    }
}
