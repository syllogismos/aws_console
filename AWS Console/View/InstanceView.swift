//
//  Instance.swift
//  AWS Console
//
//  Created by Anil Karaka on 26/05/2021.
//

import SwiftUI
import SotoEC2

struct InstanceView: View {
    var instance: EC2.Instance
    
    @EnvironmentObject var ec2Instances: EC2Instances
    
    var body: some View {
        VStack {
            ClickToCopy(text: self.instance.instanceId!)
            ClickToCopy(text: self.instance.instanceType!.rawValue)
            ClickToCopy(text: self.instance.launchTime!.description)
            ClickToCopy(text: self.instance.state?.name?.rawValue ?? "")
            ClickToCopy(text: self.instance.placement?.availabilityZone ?? "")

            HStack{
                Button(action: {ec2Instances.startInstances(instanceIds: [instance.instanceId!])}) {
                    Text("Start")
                    Image(systemName: "checkmark.circle.fill")
                }
                Button(action: {ec2Instances.stopInstances(instanceIds: [instance.instanceId!])}) {
                    Text("Stop")
                }
                Button(action: {ec2Instances.terminateInstances(instanceIds: [instance.instanceId!])}) {
                    Text("Terminate")
                }
            }
        }
    }
}

//struct InstanceView_Previews: PreviewProvider {
//    static var previews: some View {
//        InstanceView()
//    }
//}
