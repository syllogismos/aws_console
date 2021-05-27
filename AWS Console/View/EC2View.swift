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
    
    
    var body: some View {
        List(self.instances.instances, id: \.instanceId){ instance in
            NavigationLink(
                destination: InstanceView(instance: instance),
                label: {
                    Text(instance.instanceId ?? "")
                })
        }
        .navigationTitle("EC2 Instances")
        .toolbar{
            Picker(selection: $userPreferences.region, label: Text("Region")) {ForEach(regions, id: \.self){region in Text(region)}}
                .onChange(of: userPreferences.region, perform: {_ in
                    instances.getEC2Instances()
                })
            Button(action: {instances.getEC2Instances()}){
                Image(systemName: "arrow.clockwise")
            }
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
