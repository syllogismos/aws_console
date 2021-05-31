//
//  InstanceTypes.swift
//  AWS Console
//
//  Created by Anil Karaka on 29/05/2021.
//

import Foundation
import SotoEC2
import SotoPricing

class InstanceTypes: ObservableObject{
    private var accessKey: String
    private var secretKey: String
    
    private var region: String
    private var os: OperatingSystem
    
    @Published var instanceTypes = [EC2.InstanceType]()
    
    @Published var searchString = ""
    
    @Published var instanceTypeDetails: EC2.InstanceTypeInfo?
    @Published var spotPriceHistory: [EC2.SpotPrice]?
    @Published var pricingDetails: PriceDetails?
    
    func refreshKeys() {
        self.accessKey = UserDefaults.standard.object(forKey: "accessKey") as? String ?? ""
        self.secretKey = UserDefaults.standard.object(forKey: "secretKey") as? String ?? ""
        self.region = UserDefaults.standard.object(forKey: "region") as? String ?? ""
        self.os = UserDefaults.standard.object(forKey: "os") as? OperatingSystem ?? LinuxOS
    }
    
    init() {
        self.accessKey = UserDefaults.standard.object(forKey: "accessKey") as? String ?? ""
        self.secretKey = UserDefaults.standard.object(forKey: "secretKey") as? String ?? ""
        self.region = UserDefaults.standard.object(forKey: "region") as? String ?? ""
        self.os = UserDefaults.standard.object(forKey: "os") as? OperatingSystem ?? LinuxOS
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
    
    func getInstanceTypeDetails(type: String){
        print("Getting InstanceTypeDetails")
        refreshKeys()
        let client = AWSClient(credentialProvider: .static(accessKeyId: self.accessKey, secretAccessKey: self.secretKey), httpClientProvider: .createNew)
        
        let shutdown = {
            [client] in
            do {
                try client.syncShutdown()
            } catch {
                print("client shutdown error deinit in describeInstanceType")
            }
        }
        
        let ec2 = EC2(client: client, region: SotoCore.Region.init(awsRegionName: self.region))
        
        let request = EC2.DescribeInstanceTypesRequest(instanceTypes: [EC2.InstanceType(rawValue: type)])
        
        ec2.describeInstanceTypes(request)
            .whenComplete{ response in
                switch response {
                case .failure(let error):
                    print(error)
                    print("describe instance type request failed")
                    shutdown()
                case .success(let output):
                    DispatchQueue.main.async {
                        print(output)
                        self.instanceTypeDetails = output.instanceTypes?.first
                        print("describe instance type request succeeded")
                    }
                    shutdown()
                }
            }
        return
    }
    
    func getSpotPriceHistory(type: String){
        print("Getting spot price details")
        refreshKeys()
        let client = AWSClient(credentialProvider: .static(accessKeyId: self.accessKey, secretAccessKey: self.secretKey), httpClientProvider: .createNew)
        
        let shutdown = {
            [client] in
            do {
                try client.syncShutdown()
            } catch {
                print("client shutdown deinit error in getspot price details")
            }
        }
        
        let ec2 = EC2(client: client, region: SotoCore.Region.init(awsRegionName: self.region))
        
        let request = EC2.DescribeSpotPriceHistoryRequest(instanceTypes: [EC2.InstanceType(rawValue: type)], productDescriptions: [self.os.spotPriceRequestProductDescription])
        
        ec2.describeSpotPriceHistory(request)
            .whenComplete{ response in
                switch response {
                case .failure(let error):
                    print(error)
                    print("describe spot price history failed")
                    shutdown()
                case .success(let output):
                    DispatchQueue.main.async {
//                        print(output)
                        self.spotPriceHistory = output.spotPriceHistory
                        print("describe spot price history success")
                    }
                    shutdown()
                }
            }
        return
    }
    
    func getPricingDetails(type: String){
        print("Getting pricing details")
        refreshKeys()
        let client = AWSClient(credentialProvider: .static(accessKeyId: self.accessKey, secretAccessKey: self.secretKey), httpClientProvider: .createNew)
        
        let shutdown = {
            [client] in
            do {
                try client.syncShutdown()
            } catch {
                print("client shutdown deinit error in getspot price details")
            }
        }
        
        let pricing = Pricing(client: client, region: SotoCore.Region.init(awsRegionName: self.region))
        
        let request = Pricing.GetProductsRequest(filters: [Pricing.Filter(field: "instanceType", type: Pricing.FilterType.init(rawValue: "TERM_MATCH")!, value: type), Pricing.Filter(field: "location", type: Pricing.FilterType.init(rawValue: "TERM_MATCH")!, value: getRegionDescription(region: self.region)), Pricing.Filter(field: "operatingSystem", type: Pricing.FilterType.init(rawValue: "TERM_MATCH")!, value: self.os.pricingAttributeName), Pricing.Filter(field: "usagetype", type: Pricing.FilterType.init(rawValue: "TERM_MATCH")!, value: "BoxUsage:\(type)")], maxResults: 1, serviceCode: "AmazonEC2")
        
        pricing.getProducts(request)
            .whenComplete{response in
                switch response {
                case .failure(let error):
                    print(error)
                    print("pricing request failed")
                    shutdown()
                    
                case .success(let output):
                    DispatchQueue.main.async{
//                        print(output)
                        print("pricing request success")
                        let pricingDetailsString = output.priceList?.first
                        if pricingDetailsString != nil{
//                            print(pricingDetailsString!)
                            self.pricingDetails = try! JSONDecoder().decode(PriceDetails.self, from: pricingDetailsString!.data(using: .utf8)!)
//                            print(self.pricingDetails!)
                            print(self.pricingDetails?.terms.OnDemand.values.first?.priceDimensions.values.first?.pricePerUnit.USD as Any)
                        } else {
                            self.pricingDetails = getNilPrice(type: type)
                        }
                        
                    }
                    shutdown()
                }
            }
        return
    }
}
