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
    @Published var volumesStoragePrice: Double = 0.0
    @Published var volumesIOPSPrice: Double = 0.0
    @Published var volumesPrice: Double = 0.0
    @Published var volumesThroughputPrice: Double = 0.0
    
    private var subscription: AnyCancellable?
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
    
    func getVolumeIOPSPrice(volume: EC2.Volume) -> Double {
        print(self.region)
        print("volume iops pricing region")
        let iopsVolumeTypes = ["gp3", "io2", "io1"]
        let volumeType = volume.volumeType!.rawValue
        let iops = volume.iops ?? 0
        if  iopsVolumeTypes.contains(volumeType){
            let priceFunc = iopsPricing[self.region]![volumeType] ?? {(x: Int) -> Double in return 0.0}
            return priceFunc(iops)
        } else {
            return 0.0
        }
    }
    
    
    func getVolumeThroughputPrice(volume: EC2.Volume) -> Double {
        print(self.region)
        let volumeType = volume.volumeType!.rawValue
        if volumeType == "gp3" {
            let priceFunc = throughputPricing[self.region]![volumeType] ?? {(x: Int) -> Double in return 0.0}
            return priceFunc(volume.throughput ?? 0)
        } else {
            return 0.0
        }
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
                        let instances = instances_list?.flatMap {$0} ?? []
//                        print(instances ?? [])
                        // for loop for simulating more instances, change let instances to var instances
//                        for _ in 0..<5 {instances += instances}
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
                        print("voumesssssssssssss")
                        self.instanceVolumes = output.volumes ?? []
                        let volumePriceArray = self.instanceVolumes.map {(volume) -> Double in self.getVolumeStoragePrice(volume: volume)}
                        print(volumePriceArray)
                        self.volumesStoragePrice = volumePriceArray.reduce(0, +)
                        print(self.volumesStoragePrice)
                        
                        let iopsPriceArray = self.instanceVolumes.map{(volume) -> Double in self.getVolumeIOPSPrice(volume: volume)}
                        print(iopsPriceArray)
                        self.volumesIOPSPrice = iopsPriceArray.reduce(0, +)
                        print(self.volumesIOPSPrice)
                        
                        let throughputPriceArray = self.instanceVolumes.map{(volume) -> Double in self.getVolumeThroughputPrice(volume: volume)}
                        print(throughputPriceArray)
                        self.volumesThroughputPrice = throughputPriceArray.reduce(0, +)
                        
                        self.volumesPrice = self.volumesStoragePrice + self.volumesIOPSPrice + self.volumesThroughputPrice
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
                    DispatchQueue.main.async {
                        sendUserNotification(title: "Stopping instance \(instanceIds.first!) failed!", subtitle: "Try again later or check AWS web console.")
                    }
                    shutdown()
                case .success(let output):
                    print(output)
                    print("stopping instances success")
                    DispatchQueue.main.async {
                        sendUserNotification(title: "Stopped instance \(instanceIds.first!)", subtitle: "Refresh the console to see updated status")
                    }
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
                    DispatchQueue.main.async {
                        sendUserNotification(title: "Terminating instance \(instanceIds.first!) failed!", subtitle: "Try again later or check AWS web console.")
                    }
                    shutdown()
                case .success(let output):
                    print(output)
                    print("terminate instances success")
                    DispatchQueue.main.async {
                        sendUserNotification(title: "Terminated instance \(instanceIds.first!)", subtitle: "Refresh the console to see updated status")
                    }
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
                    DispatchQueue.main.async {
                        sendUserNotification(title: "Starting instance \(instanceIds.first!) failed", subtitle: "Try again!!")
                    }
                    shutdown()
                case .success(let output):
                    print(output)
                    print("starting instances success")
                    DispatchQueue.main.async {
                        sendUserNotification(title: "Started instance \(instanceIds.first!)", subtitle: "Refresh the console to see updated status")
                    }
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
