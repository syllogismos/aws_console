//
//  EC2Instances.swift
//  AWS Console
//
//  Created by Anil Karaka on 26/05/2021.
//

import Foundation
import SotoEC2
import Combine

class EC2Instances: ObservableObject {
    @Published var instances = [EC2.Instance]()
    
    private var subscription: AnyCancellable?
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
        
        self.getEC2Instances()
//        print(self.accessKey)
//        print(self.secretKey)
    }
    
    func getEC2Instances() {
        print("Getting EC2 Instances")
        refreshKeys()
        let client = AWSClient(credentialProvider: .static(accessKeyId: self.accessKey, secretAccessKey: self.secretKey), httpClientProvider: .createNew)
        print(client)
        let shutdown = {
            [client] in
            do {
                try client.syncShutdown()
            } catch {
                print("client shutdown error deinit in ec2instances")
            }
        }
        
        let ec2 = EC2(client: client, region: SotoCore.Region.init(awsRegionName: self.region))
        let request = EC2.DescribeInstancesRequest()
        ec2.describeInstances(request)
            .whenComplete{ response in
                switch response {
                case .failure(let error):
                    print(error)
                    print("Failure EC2")
                    shutdown()
                    self.instances = []
                case .success(let output):
                    DispatchQueue.main.async {
//                        print(output.reservations ?? [])
                        let instances_list = output.reservations?.map({$0.instances ?? []})
                        var instances = instances_list?.flatMap {$0} ?? []
//                        print(instances ?? [])
                        for _ in 0..<5 {instances += instances}
                        print("Success EC2")
                        self.instances = instances
                    }
                    shutdown()
                }
            }
        return
    }
    
    func stopInstances(instanceIds: [String]) {
        refreshKeys()
        let client = AWSClient(credentialProvider: .static(accessKeyId: self.accessKey, secretAccessKey: self.secretKey), httpClientProvider: .createNew)
        
        let shutdown = {
            [client] in
            do {
                try client.syncShutdown()
            } catch {
                print("client shutdown error deinit")
            }
        }
        
        
        let ec2 = EC2(client: client, region: .useast1)
        let request = EC2.StopInstancesRequest(instanceIds: instanceIds)
        ec2.stopInstances(request)
            .whenComplete{ response in
                switch response {
                case .failure(let error):
                    print(error)
                    print("stopping instances failed")
                    shutdown()
                case .success(let output):
                    print(output)
                    print("stopping instances success")
                    shutdown()
                }
            }
    }
    
    func terminateInstances(instanceIds: [String]) {
        refreshKeys()
        let client = AWSClient(credentialProvider: .static(accessKeyId: self.accessKey, secretAccessKey: self.secretKey), httpClientProvider: .createNew)
        
        let shutdown = {
            [client] in
            do {
                try client.syncShutdown()
            } catch {
                print("client shutdown error deinit")
            }
        }
        
        
        let ec2 = EC2(client: client, region: .useast1)
        let request = EC2.TerminateInstancesRequest(instanceIds: instanceIds)
        ec2.terminateInstances(request)
            .whenComplete{ response in
                switch response {
                case .failure(let error):
                    print(error)
                    print("terminate instances failed")
                    shutdown()
                case .success(let output):
                    print(output)
                    print("terminate instances success")
                    shutdown()
                }
            }
    }
    
    func startInstances(instanceIds: [String]) {
        refreshKeys()
        let client = AWSClient(credentialProvider: .static(accessKeyId: self.accessKey, secretAccessKey: self.secretKey), httpClientProvider: .createNew)
        
        let shutdown = {
            [client] in
            do {
                try client.syncShutdown()
            } catch {
                print("client shutdown error deinit")
            }
        }
        
        
        let ec2 = EC2(client: client, region: .useast1)
        let request = EC2.StartInstancesRequest(instanceIds: instanceIds)
        ec2.startInstances(request)
            .whenComplete{ response in
                switch response {
                case .failure(let error):
                    print(error)
                    print("starting instances failed")
                    shutdown()
                case .success(let output):
                    print(output)
                    print("starting instances success")
                    shutdown()
                }
            }
    }

    func test(){
        print("stupid debug statement")
        return
    }
}
