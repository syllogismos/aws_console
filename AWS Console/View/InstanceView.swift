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
//            Text("Instance Details").font(.title)
            
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        ClickToCopy(title: "Instance Id", text: self.instance.instanceId!)
                        ClickToCopy(title: "Instance Type", text: self.instance.instanceType!.rawValue)
                        ClickToCopy(title: "Launch Time", text: self.instance.launchTime!.description)
                        ClickToCopy(title: "State", text: self.instance.state?.name?.rawValue ?? "", clickToCopy: false)
                        ClickToCopy(title: "Availability Zone", text: self.instance.placement?.availabilityZone ?? "")
                    }
                    Spacer()
                    VStack(alignment: .center){
                        Button(action: {ec2Instances.startInstances(instanceIds: [self.instance.instanceId!])}) {
                            Label("Start", systemImage: "play.circle")
                        }.opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/).background(Color.green)
                        Button(action: {ec2Instances.stopInstances(instanceIds: [self.instance.instanceId!])}) {
                            Label("Stop", systemImage: "pause.circle")
                        }.background(Color.yellow).opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                        Button(action: {ec2Instances.terminateInstances(instanceIds: [self.instance.instanceId!])}) {
                            Label("Terminate", systemImage: "stop.circle")
                        }.background(Color.red).opacity(0.8)                    }
                    
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
                Spacer()
            }
        }
    }
}


struct InstanceView_Previews: PreviewProvider {
    static var previews: some View {
        //        EC2View()
        //            .environmentObject(EC2Instances())
        //            .environmentObject(UserPreferences())
        Group {
            InstanceCellView(instanceId: "asdfasdf", instanceType: "asdfa", launchTime: "asdfasdf", state: "asdfa", availabilityZone: "asdfafd", tags: [Tag(key: "asfdasd", value: "asdfasf"), Tag(key: "asdfasd", value: "asdfasfd")], securityGroups: [SecurityGroup(groupId: "asdfafds", groupName: "asdfa"), SecurityGroup(groupId: "asdfasdf", groupName: "asdfadsf")])
                .environmentObject(EC2Instances())
        }
    }
}


struct InstanceCellView: View {
    @EnvironmentObject var ec2Instances: EC2Instances
    
    var instanceId: String
    var instanceType: String
    var launchTime: String
    var state: String
    var availabilityZone: String
    var tags: [Tag]
    var securityGroups: [SecurityGroup]
    var body: some View{
        VStack {
            Text("Instance Details").font(.title)
            
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        ClickToCopy(title: "Instance Id", text: self.instanceId)
                        ClickToCopy(title: "Instance Type", text: self.instanceType)
                        ClickToCopy(title: "Launch Time", text: self.launchTime)
                        ClickToCopy(title: "State", text: self.state)
                        ClickToCopy(title: "Availability Zone", text: self.availabilityZone)
                    }
                    Spacer()
                    VStack(alignment: .center){
                        Button(action: {ec2Instances.startInstances(instanceIds: [self.instanceId])}) {
                            Text("Start")
                        }.opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/).background(Color.green)
                        Button(action: {ec2Instances.stopInstances(instanceIds: [self.instanceId])}) {
                            Text("Stop")
                        }.background(Color.yellow).opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                        Button(action: {ec2Instances.terminateInstances(instanceIds: [self.instanceId])}) {
                            Text("Terminate")
                        }.background(Color.red).opacity(0.8)                    }
                    
                }
                .padding()
                //                Divider()
                HStack {
                    VStack(alignment: .leading) {
                        Text("Security Groups").font(.title3).foregroundColor(.accentColor)
                        HStack{
                            VStack(alignment: .leading){
                                Text("Group Id").font(.caption)
                                ForEach(self.securityGroups, id: \.groupId){group in
                                    Text(group.groupId)
                                }
                            }
                            VStack(alignment: .leading){
                                Text("Group Name").font(.caption)
                                ForEach(self.securityGroups, id: \.groupId){group in
                                    Text(group.groupName)
                                }
                            }
                        }
                    }.padding().border(Color.secondary)
                    VStack(alignment: .leading) {
                        Text("Tags").font(.title3).foregroundColor(.accentColor)
                        HStack{
                            VStack(alignment: .leading){
                                Text("Key").font(.caption)
                                ForEach(self.tags, id: \.key){tag in
                                    Text(tag.key)
                                }
                            }
                            VStack(alignment: .leading){
                                Text("Value").font(.caption)
                                ForEach(self.tags, id: \.key){tag in
                                    Text(tag.value)
                                }
                            }
                        }
                    }.padding().border(Color.secondary)
                    Spacer()
                }.padding()
                Spacer()
            }
        }
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
