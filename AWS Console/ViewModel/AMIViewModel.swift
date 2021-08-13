//
//  AMIViewModel.swift
//  AWS Console
//
//  Created by Anil Karaka on 13/08/21.
//

import Foundation
import SotoEC2

class AMIViewModel: ObservableObject {
    @Published var amis = [EC2.Image]()
    
    
    private var accessKey: String
    private var secretKey: String
    private var region: String
    
    
    func refreshKeys() {
        self.accessKey = UserDefaults.standard.object(forKey: "accessKey") as? String ?? ""
        self.secretKey = UserDefaults.standard.object(forKey: "secretKey") as? String ?? ""
        self.region = UserDefaults.standard.object(forKey: "region") as? String ?? "us-east-1"
    }
    
    init() {
        self.accessKey = UserDefaults.standard.object(forKey: "accessKey") as? String ?? ""
        self.secretKey = UserDefaults.standard.object(forKey: "secretKey") as? String ?? ""
        self.region = UserDefaults.standard.object(forKey: "region") as? String ?? "us-east-1"
        
        self.getAMIs()
    }
    
    func getAMIs() {
        print("getting ami listttttttttttttttttt")
        refreshKeys()
        
        let client = AWSClient(credentialProvider: .static(accessKeyId: self.accessKey, secretAccessKey: self.secretKey), httpClientProvider: .createNew)
        
        let shutdown = {
            [client] in
            do {
                try client.syncShutdown()
            } catch {
                print("client shutdown error deinit in getamis")
            }
        }
        
        let ec2 = EC2(client: client, region: SotoCore.Region.init(awsRegionName: self.region))
        let request = EC2.DescribeImagesRequest(owners: ["self"])
        
        ec2.describeImages(request)
            .whenComplete{response in
                switch response {
                case .failure(let error):
                    print(error)
                    print("failure get amis")
                    shutdown()
                    self.amis = []
                case .success(let output):
                    print("success ami request")
                    DispatchQueue.main.async {
                        print(output.images ?? [])
                        self.amis = output.images ?? []
                    }
                    shutdown()
                }
            }
        
    }
    
}
