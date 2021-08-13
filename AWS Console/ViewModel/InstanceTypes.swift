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
    
    @Published var instanceTypes = [String]()
    
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
//                        print(output.instanceTypeOfferings!)
                        self.instanceTypes = output.instanceTypeOfferings!.map({$0.instanceType!.rawValue})
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
//                        print(output)
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
                            print(pricingDetailsString!)
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


//{
//  "product": {
//    "productFamily": "Compute Instance",
//    "attributes": {
//      "enhancedNetworkingSupported": "Yes",
//      "intelTurboAvailable": "No",
//      "memory": "32 GiB",
//      "dedicatedEbsThroughput": "3500 Mbps",
//      "vcpu": "16",
//      "capacitystatus": "AllocatedCapacityReservation",
//      "locationType": "AWS Region",
//      "storage": "EBS only",
//      "instanceFamily": "General purpose",
//      "operatingSystem": "Linux",
//      "intelAvx2Available": "No",
//      "physicalProcessor": "AWS Graviton Processor",
//      "clockSpeed": "2.3 GHz",
//      "ecu": "NA",
//      "networkPerformance": "Up to 10 Gigabit",
//      "servicename": "Amazon Elastic Compute Cloud",
//      "instancesku": "HQ3KH9WDMB6YS3JR",
//      "instanceType": "a1.4xlarge",
//      "tenancy": "Shared",
//      "usagetype": "Reservation:a1.4xlarge",
//      "normalizationSizeFactor": "32",
//      "intelAvxAvailable": "No",
//      "servicecode": "AmazonEC2",
//      "licenseModel": "No License required",
//      "currentGeneration": "Yes",
//      "preInstalledSw": "NA",
//      "location": "US East (N. Virginia)",
//      "processorArchitecture": "64-bit",
//      "operation": "RunInstances"
//    },
//    "sku": "9E428HZQ26ZUM6WT"
//  },
//  "serviceCode": "AmazonEC2",
//  "terms": {
//    "OnDemand": {
//      "9E428HZQ26ZUM6WT.JRTCKXETXF": {
//        "priceDimensions": {
//          "9E428HZQ26ZUM6WT.JRTCKXETXF.6YS6EN2CT7": {
//            "unit": "Hrs",
//            "endRange": "Inf",
//            "description": "$0.00 per Reservation Linux a1.4xlarge Instance Hour",
//            "appliesTo": [
//
//            ],
//            "rateCode": "9E428HZQ26ZUM6WT.JRTCKXETXF.6YS6EN2CT7",
//            "beginRange": "0",
//            "pricePerUnit": {
//              "USD": "0.0000000000"
//            }
//          }
//        },
//        "sku": "9E428HZQ26ZUM6WT",
//        "effectiveDate": "2021-05-01T00:00:00Z",
//        "offerTermCode": "JRTCKXETXF",
//        "termAttributes": {
//
//        }
//      }
//    }
//  },
//  "version": "20210528235622",
//  "publicationDate": "2021-05-28T23:56:22Z"
//}


//DescribeInstanceTypesResult (
//    _instanceTypes : SotoCore.OptionalCustomCoding <SotoEC2.EC2.ArrayCoder
//        <SotoEC2.EC2.DescribeInstanceTypesResult._InstanceTypesEncoding,
//            SotoEC2.EC2.InstanceTypeInfo
//        >
//    >
//    (
//        value : Optional (
//            [
//                SotoEC2.EC2.InstanceTypeInfo (
//                    autoRecoverySupported : Optional (true),
//                    bareMetal : Optional (false),
//                    burstablePerformanceSupported : Optional (false),
//                    currentGeneration : Optional (false),
//                    dedicatedHostsSupported : Optional (true),
//                    ebsInfo : Optional (
//                        SotoEC2.EC2.EbsInfo (
//                            ebsOptimizedInfo : Optional (
//                                SotoEC2.EC2.EbsOptimizedInfo (
//                                    baselineBandwidthInMbps : Optional (1750),
//                                    baselineIops : Optional (10000),
//                                    baselineThroughputInMBps : Optional (218.75),
//                                    maximumBandwidthInMbps : Optional (3500),
//                                    maximumIops : Optional (20000),
//                                    maximumThroughputInMBps : Optional (437.5)
//                                )
//                            ),
//                            ebsOptimizedSupport : Optional (default),
//                            encryptionSupport : Optional (supported),
//                            nvmeSupport : Optional (required)
//                        )
//                    ),
//                    fpgaInfo : nil,
//                    freeTierEligible : Optional (false),
//                    gpuInfo : nil,
//                    hibernationSupported : Optional (false),
//                    hypervisor : Optional (nitro),
//                    inferenceAcceleratorInfo : nil,
//                    instanceStorageInfo : nil,
//                    instanceStorageSupported : Optional (false),
//                    instanceType : Optional (SotoEC2.EC2.InstanceType(rawValue: "a1.2xlarge")),
//                    memoryInfo : Optional (SotoEC2.EC2.MemoryInfo(sizeInMiB: Optional(16384))),
//                    networkInfo : Optional (
//                        SotoEC2.EC2.NetworkInfo (
//                            defaultNetworkCardIndex : Optional (0),
//                            efaInfo : nil,
//                            efaSupported : Optional (false),
//                            enaSupport : Optional (required),
//                            ipv4AddressesPerInterface : Optional (15),
//                            ipv6AddressesPerInterface : Optional (15),
//                            ipv6Supported : Optional (true),
//                            maximumNetworkCards : Optional (1),
//                            maximumNetworkInterfaces : Optional (4),
//                            _networkCards : SotoCore.OptionalCustomCoding <SotoEC2.EC2.ArrayCoder
//                                <SotoEC2.EC2.NetworkInfo._NetworkCardsEncoding,
//                                    SotoEC2.EC2.NetworkCardInfo
//                                >
//                            >
//                            (
//                                value : Optional (
//                                    [
//                                        SotoEC2.EC2.NetworkCardInfo (
//                                            maximumNetworkInterfaces : Optional (4),
//                                            networkCardIndex : Optional (0),
//                                            networkPerformance : Optional ("Up to 10 Gigabit")
//                                        )
//                                    ]
//                                )
//                            ),
//                            networkPerformance : Optional ("Up to 10 Gigabit")
//                        )
//                    ),
//                    placementGroupInfo : Optional (
//                        SotoEC2.EC2.PlacementGroupInfo (
//                            _supportedStrategies : SotoCore.OptionalCustomCoding <SotoEC2.EC2.ArrayCoder
//                                <SotoEC2.EC2.PlacementGroupInfo._SupportedStrategiesEncoding,
//                                    SotoEC2.EC2.PlacementGroupStrategy
//                                >
//                            >
//                            (value: Optional([cluster, partition, spread]))
//                        )
//                    ),
//                    processorInfo : Optional (
//                        SotoEC2.EC2.ProcessorInfo (
//                            _supportedArchitectures : SotoCore.OptionalCustomCoding <SotoEC2.EC2.ArrayCoder
//                                <SotoEC2.EC2.ProcessorInfo._SupportedArchitecturesEncoding,
//                                    SotoEC2.EC2.ArchitectureType
//                                >
//                            >
//                            (
//                                value : Optional ([SotoEC2.EC2.ArchitectureType(rawValue: "arm64")])
//                            ),
//                            sustainedClockSpeedInGhz : Optional (2.3)
//                        )
//                    ),
//                    _supportedBootModes : SotoCore.OptionalCustomCoding <SotoEC2.EC2.ArrayCoder
//                        <SotoEC2.EC2.InstanceTypeInfo._SupportedBootModesEncoding,
//                            SotoEC2.EC2.BootModeType
//                        >
//                    >
//                    (value: Optional([uefi])),
//                    _supportedRootDeviceTypes : SotoCore.OptionalCustomCoding <SotoEC2.EC2.ArrayCoder
//                        <SotoEC2.EC2.InstanceTypeInfo._SupportedRootDeviceTypesEncoding,
//                            SotoEC2.EC2.RootDeviceType
//                        >
//                    >
//                    (value: Optional([ebs])),
//                    _supportedUsageClasses : SotoCore.OptionalCustomCoding <SotoEC2.EC2.ArrayCoder
//                        <SotoEC2.EC2.InstanceTypeInfo._SupportedUsageClassesEncoding,
//                            SotoEC2.EC2.UsageClassType
//                        >
//                    >
//                    (value: Optional([on-demand, spot])),
//                    _supportedVirtualizationTypes : SotoCore.OptionalCustomCoding <SotoEC2.EC2.ArrayCoder
//                        <SotoEC2.EC2.InstanceTypeInfo._SupportedVirtualizationTypesEncoding,
//                            SotoEC2.EC2.VirtualizationType
//                        >
//                    >
//                    (value: Optional([hvm])),
//                    vCpuInfo : Optional (
//                        SotoEC2.EC2.VCpuInfo (
//                            defaultCores : nil,
//                            defaultThreadsPerCore : nil,
//                            defaultVCpus : Optional (8),
//                            _validCores : SotoCore.OptionalCustomCoding <SotoEC2.EC2.ArrayCoder
//                                <SotoEC2.EC2.VCpuInfo._ValidCoresEncoding,
//                                    Swift.Int
//                                >
//                            >
//                            (value: nil),
//                            _validThreadsPerCore : SotoCore.OptionalCustomCoding <SotoEC2.EC2.ArrayCoder
//                                <SotoEC2.EC2.VCpuInfo._ValidThreadsPerCoreEncoding,
//                                    Swift.Int
//                                >
//                            >
//                            (value: nil)
//                        )
//                    )
//                )
//            ]
//        )
//    ),
//    nextToken : nil
//)
//
