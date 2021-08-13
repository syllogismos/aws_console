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
    @EnvironmentObject var instanceTypes: InstanceTypes
    @EnvironmentObject var userPref: UserPreferences
    @Environment(\.openURL) var openURL
    
    @ViewBuilder
    var body: some View {
        ScrollView {
            //            Text("Instance Details").font(.title)
            
            VStack {
                HStack {
                    InstanceSummary(instance: self.instance)
                    Spacer()
                    VStack(alignment: .leading){
                        Text("Current Price").font(.title3).foregroundColor(.accentColor)
                        Text("$\((self.instance.state?.name?.rawValue == "running" && self.instanceTypes.pricingDetails != nil ? Double(self.instanceTypes.pricingDetails!.terms.OnDemand.values.first?.priceDimensions.values.first?.pricePerUnit.USD ?? "-")! : 0) + self.ec2Instances.volumesPrice) per hour")
                    }.padding().border(Color.secondary)
                    Spacer()
                    VStack(alignment: .center){
                        Button(action: {openURL(URL(string: "https://console.aws.amazon.com/ec2/v2/home?region=\(userPref.region)#InstanceDetails:instanceId=\(self.instance.instanceId ?? "")")!)}){
                            Label("Open in Browser", systemImage: "network")
                        }
                        Button(action: {ec2Instances.startInstances(instanceIds: [self.instance.instanceId!])}) {
                            Label("Start", systemImage: "play.circle")
                        }.foregroundColor(Color.green)
                        Button(action: {ec2Instances.stopInstances(instanceIds: [self.instance.instanceId!])}) {
                            Label("Stop", systemImage: "pause.circle")
                        }.foregroundColor(.yellow)
                        Button(action: {ec2Instances.terminateInstances(instanceIds: [self.instance.instanceId!])}) {
                            Label("Terminate", systemImage: "stop.circle")
                        }.foregroundColor(.red)
                    }
                }
                .padding()
                HStack {
                    VStack(alignment: .leading) {
                        Text("Security Groups").font(.title3).foregroundColor(.accentColor)
                        HStack{
                            VStack(alignment: .leading){
                                Text("Group Id").font(.caption)
                                ForEach(self.instance.securityGroups ?? [], id: \.groupId){group in
                                    ClickToCopy(title: "", text: group.groupId!)
                                }
                            }
                            VStack(alignment: .leading){
                                Text("Group Name").font(.caption)
                                ForEach(self.instance.securityGroups ?? [], id: \.groupId){group in
                                    Text(group.groupName!)
                                }
                            }
                        }
                    }.padding().border(Color.secondary)
                    VStack(alignment: .leading) {
                        Text("Tags").font(.title3).foregroundColor(.accentColor)
                        HStack{
                            VStack(alignment: .leading){
                                Text("Key").font(.caption)
                                ForEach(self.instance.tags ?? [], id: \.key){tag in
                                    Text(tag.key!)
                                }
                            }
                            VStack(alignment: .leading){
                                Text("Value").font(.caption)
                                ForEach(self.instance.tags ?? [], id: \.key){tag in
                                    Text(tag.value!)
                                }
                            }
                        }
                    }.padding().border(Color.secondary)
                    
                    Spacer()
                }.padding()
                HStack{
                    VolumesView()
                    Spacer()
                }.padding()
                Spacer()
            }
        }
        .onAppear(perform: {
            instanceTypes.getPricingDetails(type: self.instance.instanceType!.rawValue)
            ec2Instances.describeVolumesOfInstance(instanceId: self.instance.instanceId!)
        })
    }
}



struct Tag {
    var key: String
    var value: String
}

struct SecurityGroup {
    var groupId: String
    var groupName: String
}

struct InstanceSummary: View {
    var instance: EC2.Instance
    @EnvironmentObject var instanceTypes: InstanceTypes
    
    
    @ViewBuilder
    var body: some View {
        VStack(alignment: .leading){
            Group {
                ClickToCopy(title: "Instance Id", text: self.instance.instanceId!)
                ClickToCopy(title: "Instance Type", text: self.instance.instanceType!.rawValue)
                ClickToCopy(title: "Launch Time", text: self.instance.launchTime!.description)
                ClickToCopy(title: "State", text: self.instance.state?.name?.rawValue ?? "", clickToCopy: false)
                    .foregroundColor(instance.state?.name?.rawValue ?? "" == "running" ? Color.green : Color.primary)
                ClickToCopy(title: "Availability Zone", text: self.instance.placement?.availabilityZone ?? "")
                ClickToCopy(title: "Public IP", text: self.instance.publicIpAddress ?? "-")
                ClickToCopy(title: "Public DNS", text: self.instance.publicDnsName ?? "-")
            }
            Group {
                ClickToCopy(title: "Private IP", text: self.instance.privateIpAddress ?? "")
                ClickToCopy(title: "Private DNS", text: self.instance.privateDnsName ?? "")
                ClickToCopy(title: "VPC Id", text: self.instance.vpcId ?? "")
                if instanceTypes.pricingDetails != nil {
                    ClickToCopy(title: "Price Per Hour", text: self.instanceTypes.pricingDetails!.terms.OnDemand.values.first?.priceDimensions.values.first?.pricePerUnit.USD ?? "-", clickToCopy: false)
                }
                ClickToCopy(title: "Key", text: self.instance.keyName ?? "")
                ClickToCopy(title: "Image", text: self.instance.imageId ?? "")
            }
            
        }
        
    }
}

struct VolumesView: View {
    @EnvironmentObject var ec2Instances: EC2Instances

    var body: some View {
        VStack(alignment: .leading) {
            Text("Volumes").font(.title3).foregroundColor(.accentColor)
            HStack{
                VStack(alignment: .leading){
                    Text("Device Name").font(.caption)
                    ForEach(ec2Instances.instanceVolumes , id: \.volumeId){volume in
                        Text((volume.attachments?.first!.device!)!)
                    }
                }
                VStack(alignment: .leading){
                    Text("Volume Id").font(.caption)
                    ForEach(ec2Instances.instanceVolumes, id: \.volumeId){volume in
                        ClickToCopy(title: "", text: volume.volumeId!)
                    }
                }
                VStack(alignment: .leading){
                    Text("Type").font(.caption)
                    ForEach(ec2Instances.instanceVolumes, id: \.volumeId){volume in
                        Text(volume.volumeType!.rawValue)
                    }
                }
                VStack(alignment: .leading){
                    Text("Size").font(.caption)
                    ForEach(ec2Instances.instanceVolumes, id: \.volumeId){volume in
                        Text(volume.size!.description)
                    }
                }
                VStack(alignment: .leading){
                    Text("IOPS").font(.caption)
                    ForEach(ec2Instances.instanceVolumes, id: \.volumeId){volume in
                        Text(volume.iops!.description)
                    }
                }
                VStack(alignment: .leading){
                    Text("Delete on Termination").font(.caption)
                    ForEach(ec2Instances.instanceVolumes, id: \.volumeId){volume in
                        Text(volume.attachments?.first!.deleteOnTermination?.description ?? "")
                    }
                }
                VStack(alignment: .leading){
                    Text("Price per hour").font(.caption)
                    ForEach(ec2Instances.instanceVolumes, id: \.volumeId){volume in
                        Text(ec2Instances.getVolumeStoragePrice(volume: volume).description)
                    }
                }
            }
        }.padding().border(Color.secondary)
    }
}
