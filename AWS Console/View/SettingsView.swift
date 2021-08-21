//
//  SettingsView.swift
//  AWS Console
//
//  Created by Anil Karaka on 25/05/2021.
//

import SwiftUI
import SotoEC2
import UserNotifications


struct SettingsView: View {
    var body: some View {
        List{
            NavigationLink(
                destination: KeysView(),
                label: {
                    Label("Keys", systemImage: "key")
                })
            NavigationLink(
                destination: Support(),
                label: {
                    Label("Support", systemImage: "questionmark.circle")
                }
            )
            NavigationLink(
                destination: ChangeLog(),
                label: {
                    Label("Change Log", systemImage: "list.dash")
                }
            )
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
        KeysView().environmentObject(UserPreferences())
        Support()
        ChangeLog()
    }
}

struct Support: View {
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            Group{
                Text("Email me at ") +
                Text("anilkaraka@outlook.com").foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/) +
                Text(" if you find any bugs or have feature requests.")
            }.font(.title)
            Spacer()
            Link("Privacy Policy", destination: URL(string: "https://github.com/syllogismos/Compute-Manager/blob/main/Privacy%20Policy.md")!)
        }.frame(maxWidth: .infinity, maxHeight: .infinity).padding()
    }
}

struct ChangeLog: View {
    var body: some View {
        VStack {
            ScrollView {
                Text("Change Log").font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                HStack {
                    VStack(alignment: .leading) {
                        Text("Date: 21st August 2021").font(.caption)
                        Text("EC2").font(.subheadline .bold())
                        Text(
    """
    ‣ Browse Instances
    ‣ Display current price of the instance including the EBS costs, per day.
    ‣ This works even for spot instances according to their current price.
    ‣ Start/Stop/Terminate Instances from the console.
    ‣ Open AWS web launch wizard when you are starting a new instance.
    ‣ Show all available instance types, their price and their current spot price from various availability zones.
    ‣ Additional confirmation when you are terminating an instance.
    """)
                        Text("S3").font(.subheadline .bold())
                        Text(
    """
    ‣ S3 File Browser.
    ‣ Drag and drop files from your computer to upload to a given bucket/folder location on S3.
    ‣ Progress bar for file uploads, but not folders.
    ‣ Create a new Bucket from Compute Manager.
    ‣ Right click on an object gives you options to delete/open directly from the app.
    """)
                    }
                        
                    Spacer()
                }
            }
            Spacer()
            Group{
                Text("Feel free to email me at ") +
                Text("anilkaraka@outlook.com").foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/) +
                Text(" if you find any bugs or have feature requests.")
            }.font(.footnote)
        }.frame(maxWidth: .infinity, maxHeight: .infinity).padding()
    }
}

struct KeysView: View {
    @EnvironmentObject var userPreferences: UserPreferences
    @Environment(\.openURL) var openURL
    
    @State var hideKeys = true
    
    var body: some View{
        VStack{
            
            //            Text("Preferences")
            //                .font(.title)
            //                .multilineTextAlignment(.leading)
            
            
            HStack{
                VStack{
                    HStack{
                        Text("Access Key:")
                        if hideKeys {
                            SecureField("Access Key", text: $userPreferences.accessKey)
                        } else {
                            TextField("Access Key", text: $userPreferences.accessKey)
                        }
                    }
                    HStack{
                        Text("Access Secret:")
                        if hideKeys{
                            SecureField("Access Secret", text: $userPreferences.secretKey)
                        } else {
                            TextField("Access Secret", text: $userPreferences.secretKey)
                        }
                    }
                    
                }.frame(maxWidth: 350)
                Button{openURL(URL(string: "https://console.aws.amazon.com/iamv2/home?#/users")!)} label: {
                    Text("Create a new key pair")
                }
                Spacer()
            }
            HStack() {
                Toggle("Hide Keys", isOn: $hideKeys)
                Spacer()
                
                
            }
            
            
            HStack {
                Picker(selection: $userPreferences.region, label: Text("Default Region:")) {
                    ForEach(regions, id: \.self) { region in Text(region)
                    }
                }
                .frame(minWidth: 150, maxWidth: 200)
                .clipped()
                //                Button{checkAWSClient(accessKey: userPreferences.accessKey, secretKey: userPreferences.secretKey)} label: {
                //                    Text("Check AWS Credentials")
                //                }
                Button{enableNotifications()} label: {
                    Text("Enable Notifications")
                }
                Button{sendUserNotification(title: "Feed the dog", subtitle: "Dog is hungry")} label: {
                    Text("Test Notification")
                }
                Spacer()
                
            }
            Spacer()
            HStack{
                Text("You can find the instructions on how to create a new key pair")
                Link("here", destination: URL(string: "https://github.com/syllogismos/Compute-Manager")!)
                
            }.font(.footnote)
        }
        //        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}


func checkAWSClient(accessKey: String, secretKey: String){
    print("Checking aws client")
    //    let client = AWSClient(
    //        credentialProvider: .static(accessKeyId: "AKIAQXYM4IF3ZZAMHTNE", secretAccessKey: "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"),
    //        httpClientProvider: .createNew
    //    )
    let client = AWSClient(credentialProvider: .static(accessKeyId: accessKey, secretAccessKey: secretKey), httpClientProvider: .createNew)
    print(client)
    let shutdown = {[client] in     // << capture client
        do {
            try client.syncShutdown()
        } catch {
            print("client shutdown error deinit")
        }
    }
    //    let s3 = S3(client: client, region: .useast1)
    //    s3.listBuckets()
    //        .whenComplete {response in
    //            switch response {
    //            case .failure(let error):
    //                print(error)
    //                print("Failure s3")
    //
    //            case .success(let output):
    //                print(output)
    //                print("Success s3")
    //
    //            }
    //        }
    
    let ec2 = EC2(client: client, region: .useast1)
    let describeInstancesRequest = EC2.DescribeInstancesRequest(dryRun: false)
    ec2.describeInstances(describeInstancesRequest)
        .whenComplete {response in
            switch response {
            case .failure(let error):
                print(error)
                print("Failure EC2")
                shutdown()
            case .success(let output):
                print(output)
                print("Success EC2")
                shutdown()
            }
        }
}

func enableNotifications() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
        if success {
            print("All set!")
        } else if let error = error {
            print(error.localizedDescription)
        }
    }
}
