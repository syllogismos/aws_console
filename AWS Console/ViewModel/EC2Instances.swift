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
    @Published var searchString = ""
    @Published var instanceVolumes = [EC2.Volume]()
    
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
    
    func getVolumeStoragePrice(volume: EC2.Volume) -> Double {
        print(self.region)
        print("volume pricing region")
        let size = Double(volume.size ?? 0)
        let gb_month = storagePricing[self.region]![volume.volumeType!.rawValue] ?? 0.0
        
        //$0.08 per GB-month * 2000 GB * 43,200 seconds / (86,400 seconds/day * 30 day-month)
        // above is the formula for 12 hours * 3600 = 43200 seconds of usage
        // approx forumla for 1 hour = gb-month * size * 3600 /(86400 * 30)
        let price_per_hour = size * gb_month * 3600 / (86400 * 30)
        
        // round to 4 decimal places
        let rounded_price = Double(round(10000*price_per_hour)/10000)

        return rounded_price
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
//                        self.searchInstanceString(i: <#T##EC2.Instance#>, searchString: <#T##String#>)(i: self.instances.first!, searchString: "")
                    }
                    shutdown()
                }
            }
        return
    }
    
    func describeVolumesOfInstance(instanceId: String) {
        print(self.region)
        print("rrrrrrrrrrrrrrrrrrrrrrrrrrrr")
        refreshKeys()
        let client = AWSClient(credentialProvider: .static(accessKeyId: self.accessKey, secretAccessKey: self.secretKey), httpClientProvider: .createNew)
        
        let shutdown = {
            [client] in
            do {
                try client.syncShutdown()
            } catch {
                print("client shutdown error deinit describevolumes")
            }
        }
        
        let ec2 = EC2(client: client, region: SotoCore.Region.init(awsRegionName: self.region))
        
        let request = EC2.DescribeVolumesRequest(filters: [EC2.Filter(name: "attachment.instance-id", values: [instanceId])])
        ec2.describeVolumes(request)
            .whenComplete{ response in
                switch response {
                case .failure(let error):
                    print(error)
                    print("Failure describe volumes")
                    self.instanceVolumes = []
                    shutdown()
                case .success(let output):
                    print(output)
                    print("asfafafafafa")
                    DispatchQueue.main.async {
                        self.instanceVolumes = output.volumes ?? []
                    }
                    shutdown()
                }
            }
        
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
        
        
        let ec2 = EC2(client: client, region: SotoCore.Region.init(awsRegionName: self.region))
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
        
        
        let ec2 = EC2(client: client, region: SotoCore.Region.init(awsRegionName: self.region))
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
        
        
        let ec2 = EC2(client: client, region: SotoCore.Region.init(awsRegionName: self.region))
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
    
    func searchInstanceString(i: EC2.Instance, searchString: String) -> Bool{
        let tags = i.tags ?? []
        let groups = i.securityGroups ?? []

        let instanceString = "\(i.capacityReservationId ?? "") \(i.instanceId ?? "") \(i.clientToken ?? "") \(i.imageId ?? "") \(i.kernelId ?? "") \(i.privateDnsName ?? "") \(String(describing: i.privateIpAddress)) \(i.publicDnsName ?? "") \(String(describing: i.publicIpAddress)) \(i.instanceType?.rawValue ?? "")  \(i.outpostArn ?? "") \(i.placement!.availabilityZone ?? "") \(tags.map({$0.key ?? ""}).joined(separator: ", ")) \(tags.map({$0.value ?? ""}).joined(separator: ", ")) \(groups.map({$0.groupId ?? ""}).joined(separator: ", ")) \(groups.map({$0.groupName ?? ""}).joined(separator: ", ")) \(i.vpcId ?? "") \(i.state?.name?.rawValue ?? "")"
        
//        print(instanceString)
    
        return instanceString.contains(searchString)
    }
}
