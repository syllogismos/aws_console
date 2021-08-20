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
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
        KeysView().environmentObject(UserPreferences())
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
