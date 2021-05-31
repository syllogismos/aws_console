//
//  OSModel.swift
//  AWS Console
//
//  Created by Anil Karaka on 31/05/2021.
//

import Foundation



//
//o product-description - The product description for the  Spot  price
//  (Linux/UNIX  |  Red  Hat Enterprise Linux | SUSE Linux | Windows |
//  Linux/UNIX (Amazon VPC) | Red Hat Enterprise Linux (Amazon VPC)  |
//  SUSE Linux (Amazon VPC) | Windows (Amazon VPC) ).

//$ aws pricing get-attribute-values \
//              --service-code AmazonEC2 \
//              --attribute-name operatingSystem
//{
//    "AttributeValues": [
//        {
//            "Value": "Linux"
//        },
//        {
//            "Value": "NA"
//        },
//        {
//            "Value": "RHEL"
//        },
//        {
//            "Value": "Red Hat Enterprise Linux with HA"
//        },
//        {
//            "Value": "SUSE"
//        },
//        {
//            "Value": "Windows"
//        }
//    ]
//}


struct OperatingSystem: Hashable {
    let pricingAttributeName: String
    let spotPriceRequestProductDescription: String
    let name: String
}

let LinuxOS = OperatingSystem(pricingAttributeName: "Linux", spotPriceRequestProductDescription: "Linux/UNIX (Amazon VPC)", name: "Linux")

let RHEL = OperatingSystem(pricingAttributeName: "RHEL", spotPriceRequestProductDescription: "Red Hat Enterprise Linux", name: "RHEL")

let RHELHA = OperatingSystem(pricingAttributeName: "Red Hat Enterprise Linux with HA", spotPriceRequestProductDescription: "Red Hat Enterprise Linux with HA", name: "RHEL HA")

let SUSE = OperatingSystem(pricingAttributeName: "SUSE", spotPriceRequestProductDescription: "SUSE Linux (Amazon VPC)", name: "SUSE")

let Windows = OperatingSystem(pricingAttributeName: "Windows", spotPriceRequestProductDescription: "Windows", name: "Windows")

let OSList = [LinuxOS, RHEL, RHELHA, SUSE, Windows]
