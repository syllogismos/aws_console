//
//  VolumePricingHelper.swift
//  AWS Console
//
//  Created by Anil Karaka on 14/07/2021.
//

import Foundation

import SotoEC2
// https://aws.amazon.com/ebs/pricing/
let storagePricing = [
    "af-south-1": ["gp3": 0.1047, "gp2": 0.1309, "io1": 0.16422, "st1": 0.0595, "sc1": 0.019992],
    "ap-east-1": ["gp3": 0.1056, "gp2": 0.132, "io2": 0.1518, "io1": 0.1518, "st1": 0.0594, "sc1": 0.0198],
    "ap-northeast-1": ["gp3": 0.096, "gp2": 0.12, "io2": 0.142, "io1": 0.142, "st1": 0.054, "sc1": 0.018],
    "ap-northeast-2": ["gp3": 0.0912, "gp2": 0.114, "io2": 0.1278, "io1": 0.1278, "st1": 0.051, "sc1": 0.0174],
    "ap-northeast-3": ["gp3": 0.096, "gp2": 0.12, "io1": 0.142, "st1": 0.054, "sc1": 0.018],
    "ap-south-1": ["gp3": 0.0912, "gp2": 0.114, "io2": 0.131, "io1": 0.131, "st1": 0.051, "sc1": 0.0174],
    "ap-southeast-1": ["gp3": 0.096, "gp2": 0.12, "io2": 0.138, "io1": 0.138, "st1": 0.054, "sc1": 0.018],
    "ap-southeast-2": ["gp3": 0.096, "gp2": 0.12, "io2": 0.138, "io1": 0.138, "st1": 0.054, "sc1": 0.018],
    "ca-central-1": ["gp3": 0.088, "gp2": 0.11, "io2": 0.072, "io1": 0.138, "st1": 0.05, "sc1": 0.0168],
    "eu-central-1": ["gp3": 0.0952, "gp2": 0.119, "io2": 0.149, "io1": 0.149, "st1": 0.054, "sc1": 0.018],
    "eu-north-1": ["gp3": 0.0836, "gp2": 0.1045, "io2": 0.1311, "io1": 0.1311, "st1": 0.0475, "sc1": 0.01596],
    "eu-south-1": ["gp3": 0.0924, "gp2": 0.1155, "io1": 0.1449, "st1": 0.0525, "sc1": 0.01764],
    "eu-west-1": ["gp3": 0.088, "gp2": 0.11, "io2": 0.072, "io1": 0.138, "st1": 0.05, "sc1": 0.0168],
    "eu-west-2": ["gp3": 0.0928, "gp2": 0.116, "io2": 0.145, "io1": 0.145, "st1": 0.053, "sc1": 0.0174],
    "eu-west-3": ["gp3": 0.0928, "gp2": 0.116, "io1": 0.145, "st1": 0.053, "sc1": 0.0174],
    "me-south-1": ["gp3": 0.0968, "gp2": 0.121, "io2": 0.1518, "io1": 0.1518, "st1": 0.055, "sc1": 0.01848],
    "sa-east-1": ["gp3": 0.152, "gp2": 0.19, "io1": 0.238, "st1": 0.086, "sc1": 0.0288],
    "us-east-1": ["gp3": 0.08, "gp2": 0.10, "io2": 0.125, "io1": 0.125, "st1": 0.045, "sc1": 0.015],
    "us-east-2": ["gp3": 0.08, "gp2": 0.10, "io2": 0.125, "io1": 0.125, "st1": 0.045, "sc1": 0.015],
    "us-west-1": ["gp3": 0.096, "gp2": 0.12, "io2": 0.138, "io1": 0.138, "st1": 0.054, "sc1": 0.018],
    "us-west-2": ["gp3": 0.08, "gp2": 0.10, "io2": 0.125, "io1": 0.125, "st1": 0.045, "sc1": 0.015],
] as [String : [String: Double]]

let mult = 3600.0 / (86400.0*30.0)


func gp3IOPS(price: Double) -> (Int) -> Double {
    return {(x: Int) -> Double in
        if x < 3000 {
            return 0.0
        } else {
            return price*Double((x - 3000))*mult
        }
    }
}

func io1IOPS(price: Double) -> (Int) -> Double {
    return {(x: Int) -> Double in price*Double(x)*mult}
}

func io2IOPS(p1: Double, p2: Double, p3: Double) -> (Int) -> Double {
    return {(x: Int) -> Double in
        if x < 32000 {
            return p1*Double(x)*mult
        }
        if x < 64000 {
            return (p1*Double(32000) + p2*Double(x-32000))*mult
        }
        return (p1*Double(32000) + p2*Double(32000) + p3*Double(x-64000))*mult
    }
}


let iopsPricing = [
    "us-east-1": [
        "gp3": gp3IOPS(price: 0.005),
        "io2": io2IOPS(p1: 0.065, p2: 0.046, p3: 0.032),
        "io1": io1IOPS(price: 0.065)
    ],
    "us-east-2": [
        "gp3": gp3IOPS(price: 0.005),
        "io2": io2IOPS(p1: 0.065, p2: 0.046, p3: 0.032),
        "io1": io1IOPS(price: 0.065)
    ],
    "af-south-1": [
        "gp3": gp3IOPS(price: 0.0065),
        "io1": io1IOPS(price: 0.08568)
    ],
    "ap-east-1": [
        "gp3": gp3IOPS(price: 0.0066),
        "io2": io2IOPS(p1: 0.079, p2: 0.055, p3: 0.039),
        "io1": io1IOPS(price: 0.0792)
    ],
    "ap-northeast-1": [
        "gp3": gp3IOPS(price: 0.006),
        "io2": io2IOPS(p1: 0.074, p2: 0.052, p3: 0.036),
        "io1": io1IOPS(price: 0.074)
    ],
    "ap-northeast-2": [
        "gp3": gp3IOPS(price: 0.0057),
        "io2": io2IOPS(p1: 0.067, p2: 0.047, p3: 0.033),
        "io1": io1IOPS(price: 0.0666)
    ],
    "ap-northeast-3": [
        "gp3": gp3IOPS(price: 0.006),
        "io1": io1IOPS(price: 0.074)
    ],
    "ap-south-1": [
        "gp3": gp3IOPS(price: 0.0057),
        "io2": io2IOPS(p1: 0.068, p2: 0.048, p3: 0.033),
        "io1": io1IOPS(price: 0.068)
    ],
    "ap-southeast-1": [
        "gp3": gp3IOPS(price: 0.006),
        "io2": io2IOPS(p1: 0.072, p2: 0.050, p3: 0.035),
        "io1": io1IOPS(price: 0.072)
    ],
    "ap-southeast-2": [
        "gp3": gp3IOPS(price: 0.006),
        "io2": io2IOPS(p1: 0.072, p2: 0.050, p3: 0.035),
        "io1": io1IOPS(price: 0.072)
    ],
    "ca-central-1": [
        "gp3": gp3IOPS(price: 0.0055),
        "io2": io2IOPS(p1: 0.072, p2: 0.050, p3: 0.035),
        "io1": io1IOPS(price: 0.072)
    ],
    "eu-central-1": [
        "gp3": gp3IOPS(price: 0.006),
        "io2": io2IOPS(p1: 0.078, p2: 0.055, p3: 0.038),
        "io1": io1IOPS(price: 0.078)
    ],
    "eu-north-1": [
        "gp3": gp3IOPS(price: 0.0052),
        "io2": io2IOPS(p1: 0.068, p2: 0.048, p3: 0.034),
        "io1": io1IOPS(price: 0.0684)
    ],
    "eu-south-1": [
        "gp3": gp3IOPS(price: 0.0058),
        "io1": io1IOPS(price: 0.0756)
    ],
    "eu-west-1": [
        "gp3": gp3IOPS(price: 0.0055),
        "io2": io2IOPS(p1: 0.072, p2: 0.050, p3: 0.035),
        "io1": io1IOPS(price: 0.072)
    ],
    "eu-west-2": [
        "gp3": gp3IOPS(price: 0.0058),
        "io2": io2IOPS(p1: 0.076, p2: 0.053, p3: 0.037),
        "io1": io1IOPS(price: 0.076)
    ],
    "eu-west-3": [
        "gp3": gp3IOPS(price: 0.0058),
        "io1": io1IOPS(price: 0.076)
    ],
    "me-south-1": [
        "gp3": gp3IOPS(price: 0.0061),
        "io2": io2IOPS(p1: 0.079, p2: 0.055, p3: 0.039),
        "io1": io1IOPS(price: 0.0792)
    ],
    "sa-east-1": [
        "gp3": gp3IOPS(price: 0.0095),
        "io1": io1IOPS(price: 0.091)
    ],
    "us-west-1": [
        "gp3": gp3IOPS(price: 0.006),
        "io2": io2IOPS(p1: 0.072, p2: 0.050, p3: 0.035),
        "io1": io1IOPS(price: 0.072)
    ],
    "us-west-2": [
        "gp3": gp3IOPS(price: 0.005),
        "io2": io2IOPS(p1: 0.065, p2: 0.046, p3: 0.032),
        "io1": io1IOPS(price: 0.065)
    ]
    
] as [String: [String: (Int) -> Double]]



