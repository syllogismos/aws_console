//
//  Regions.swift
//  AWS Console
//
//  Created by Anil Karaka on 31/05/2021.
//

import Foundation


func getRegionDescription(region: String) -> String{
    switch region {
    case "af-south-1":
        return "Africa (Cape Town)"
    case "ap-east-1":
        return "Asia Pacific (Hong Kong)"
    case "ap-northeast-1":
        return "Asia Pacific (Tokyo)"
    case "ap-northeast-2":
        return "Asia Pacific (Seoul)"
    case "ap-northeast-3":
        return "Asia Pacific (Osaka Local)"
    case "ap-south-1":
        return "Asia Pacific (Mumbai)"
    case "ap-southeast-1":
        return "Asia Pacific (Singapore)"
    case "ap-southeast-2":
        return "Asia Pacific (Sydney)"
    case "ca-central-1":
        return "Canada (Central)"
    case "cn-north-1":
        return "China (Beijing)"
    case "cn-northwest-1":
        return "China (Ningxia)"
    case "eu-central-1":
        return "Europe (Frankfurt)"
    case "eu-north-1":
        return "Europe (Stockholm)"
    case "eu-south-1":
        return "Europe (Milan)"
    case "eu-west-1":
        return "Europe (Ireland)"
    case "eu-west-2":
        return "Europe (London)"
    case "eu-west-3":
        return "Europe (Paris)"
    case "me-south-1":
        return "Middle East (Bahrain)"
    case "sa-east-1":
        return "South America (Sao Paulo)"
    case "us-east-1":
        return "US East (N. Virginia)"
    case "us-east-2":
        return "US East (Ohio)"
    case "us-gov-east-1":
        return "AWS GovCloud (US-East)"
    case "us-gov-west-1":
        return "AWS GovCloud (US-West)"
    case "us-iso-east-1":
        return "US ISO East"
    case "us-isob-east-1":
        return "US ISOB East (Ohio)"
    case "us-west-1":
        return "US West (N. California)"
    case "us-west-2":
        return "US West (Oregon)"
    default:
        return "Not Proper Region"
    }
}
