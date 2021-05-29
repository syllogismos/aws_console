//
//  InstanceTypes.swift
//  AWS Console
//
//  Created by Anil Karaka on 29/05/2021.
//

import Foundation
import SotoEC2

class InstanceTypes: ObservableObject{
    private var accessKey: String
    private var secretKey: String
    
    private var region: String
    
    @Published var instanceTypes = [EC2.InstanceType]()
    
    @Published var searchString = ""
    
    func refreshKeys() {
        self.accessKey = UserDefaults.standard.object(forKey: "accessKey") as? String ?? ""
        self.secretKey = UserDefaults.standard.object(forKey: "secretKey") as? String ?? ""
        self.region = UserDefaults.standard.object(forKey: "region") as? String ?? ""
    }
    
    init() {
        self.accessKey = UserDefaults.standard.object(forKey: "accessKey") as? String ?? ""
        self.secretKey = UserDefaults.standard.object(forKey: "secretKey") as? String ?? ""
        self.region = UserDefaults.standard.object(forKey: "region") as? String ?? ""
        self.getInstanceOfferings()
    }
    
    
    func getInstanceOfferings(){
        print("Getting InstanceOfferings of a region")
        refreshKeys()
        
        let client = AWSClient(credentialProvider: .static(accessKeyId: self.accessKey, secretAccessKey: self.secretKey), httpClientProvider: .createNew)
        
        let shutdown = {
            [client] in
            do {
                try client.syncShutdown()
            } catch {
                print("client shutdown error deinit in instancetypes")
            }
        }
        
        let ec2 = EC2(client: client, region: SotoCore.Region.init(awsRegionName: self.region))
        
        let request = EC2.DescribeInstanceTypeOfferingsRequest()
        
        // (filters: [EC2.Filter(name: "region", values: [self.region])])
        
        ec2.describeInstanceTypeOfferings(request)
            .whenComplete{ response in
                switch response {
                case .failure(let error):
                    print(error)
                    self.instanceTypes = []
                    print("instance type offering request failed")
                    shutdown()
                case .success(let output):
                    DispatchQueue.main.async {
                        print(output.instanceTypeOfferings!)
                        self.instanceTypes = output.instanceTypeOfferings!.map({$0.instanceType!})
//                        self.categorizeTypes()
                        print("Success instance type offering request")
                    }
                    shutdown()
                }
            }
        return
    }
}
