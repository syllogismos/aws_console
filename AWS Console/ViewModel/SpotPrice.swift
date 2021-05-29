//
//  SpotPrice.swift
//  AWS Console
//
//  Created by Anil Karaka on 29/05/2021.
//

import Foundation
import SotoEC2

class SpotPrice: ObservableObject{
    private var accessKey: String
    private var secretKey: String
    
    private var region: String
    
    func refreshKeys() {
        self.accessKey = UserDefaults.standard.object(forKey: "accessKey") as? String ?? ""
        self.secretKey = UserDefaults.standard.object(forKey: "secretKey") as? String ?? ""
        self.region = UserDefaults.standard.object(forKey: "region") as? String ?? ""
    }
    
    init() {
        self.accessKey = UserDefaults.standard.object(forKey: "accessKey") as? String ?? ""
        self.secretKey = UserDefaults.standard.object(forKey: "secretKey") as? String ?? ""
        self.region = UserDefaults.standard.object(forKey: "region") as? String ?? ""
    }
    
    func getSpotPriceHistory(instanceType: String){
        print("Getting Spot Price history \(instanceType)")
        refreshKeys()
        
        let client = AWSClient(credentialProvider: .static(accessKeyId: self.accessKey, secretAccessKey: self.secretKey), httpClientProvider: .createNew)
        let shutdown = {
            [client] in
            do {
                try client.syncShutdown()
            } catch {
                print("client shutdown error deinit in spotprice")
            }
        }
        
        let ec2 = EC2(client: client, region: SotoCore.Region.init(awsRegionName: self.region))
        
        let request = EC2.DescribeSpotPriceHistoryRequest(instanceTypes: [EC2.InstanceType.init(rawValue: instanceType)], productDescriptions: ["Linux/UNIX (Amazon VPC)"])
        
        ec2.describeSpotPriceHistory(request)
            .whenComplete{ response in
                switch response {
                case .failure(let error):
                    print(error)
                    print("spot price request failed")
                    shutdown()
                case .success(let output):
                    DispatchQueue.main.async {
                        print(output)
                        print("Success spot price request")
                    }
                    shutdown()
                }
            }
        return
    }
}
