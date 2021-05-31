//
//  InstancePricingModel.swift
//  AWS Console
//
//  Created by Anil Karaka on 31/05/2021.
//

import Foundation

typealias PricingResponse = [PriceDetails]

struct PriceDetails: Codable {
    let product: Product!
    let serviceCode: String!
    let terms: Terms!
}

struct Product: Codable {
    let productFamily: String!
    let attributes: ProductAttributes!
}

struct ProductAttributes: Codable {
    let memory: String!
    let dedicatedEbsThroughput: String!
    let vcpu: String!
    let storage: String!
    let instanceFamily: String!
    let physicalProcessor: String!
    let clockSpeed: String!
    let ecu: String!
    let networkPerformance: String!
    let instanceType: String!
    let servicecode: String!
    let usagetype: String!
}

struct Terms: Codable {
    let OnDemand: [String: OnDemandAttributes]
}

struct OnDemandAttributes: Codable {
    let sku, effectiveDate, offerTermCode: String!
    let priceDimensions: [String: PriceDimensionsAttributes]
}

struct PriceDimensionsAttributes: Codable {
    let unit, endRange, description, rateCode: String!
    let pricePerUnit: PricePerUnit!
}

struct PricePerUnit: Codable {
    let USD: String!
}

func getNilPrice(type: String) -> PriceDetails {
    return PriceDetails(product: Product(productFamily: "Compute Instance", attributes: ProductAttributes(memory: "", dedicatedEbsThroughput: "", vcpu: "", storage: "", instanceFamily: "", physicalProcessor: "", clockSpeed: "", ecu: "", networkPerformance: "", instanceType: type, servicecode: "AmazonEC2", usagetype: "")), serviceCode: "AmazonEC2", terms: Terms(OnDemand: ["sku": OnDemandAttributes(sku: "sku", effectiveDate: "", offerTermCode: "", priceDimensions: ["sku": PriceDimensionsAttributes(unit: "", endRange: "", description: "", rateCode: "", pricePerUnit: PricePerUnit(USD: "?"))])]))
}

//{
//  "product": {
//    "productFamily": "Compute Instance",
//    "attributes": {
//      "enhancedNetworkingSupported": "No",
//      "intelTurboAvailable": "Yes",
//      "memory": "30 GiB",
//      "dedicatedEbsThroughput": "1000 Mbps",
//      "vcpu": "8",
//      "capacitystatus": "Used",
//      "locationType": "AWS Region",
//      "storage": "2 x 80 SSD",
//      "instanceFamily": "General purpose",
//      "operatingSystem": "RHEL",
//      "intelAvx2Available": "No",
//      "physicalProcessor": "Intel Xeon E5-2670 v2 (Ivy Bridge/Sandy Bridge)",
//      "clockSpeed": "2.5 GHz",
//      "ecu": "26",
//      "networkPerformance": "High",
//      "servicename": "Amazon Elastic Compute Cloud",
//      "instanceType": "m3.2xlarge",
//      "tenancy": "Shared",
//      "usagetype": "BoxUsage:m3.2xlarge",
//      "normalizationSizeFactor": "16",
//      "intelAvxAvailable": "Yes",
//      "processorFeatures": "Intel AVX; Intel Turbo",
//      "servicecode": "AmazonEC2",
//      "licenseModel": "No License required",
//      "currentGeneration": "No",
//      "preInstalledSw": "NA",
//      "location": "US East (N. Virginia)",
//      "processorArchitecture": "64-bit",
//      "operation": "RunInstances:0010"
//    },
//    "sku": "26EZN83WFYW935BY"
//  },
//  "serviceCode": "AmazonEC2",
//  "terms": {
//    "OnDemand": {
//      "26EZN83WFYW935BY.JRTCKXETXF": {
//        "priceDimensions": {
//          "26EZN83WFYW935BY.JRTCKXETXF.6YS6EN2CT7": {
//            "unit": "Hrs",
//            "endRange": "Inf",
//            "description": "zsh.662 per On Demand RHEL m3.2xlarge Instance Hour",
//            "appliesTo": [],
//            "rateCode": "26EZN83WFYW935BY.JRTCKXETXF.6YS6EN2CT7",
//            "beginRange": "0",
//            "pricePerUnit": {
//              "USD": "0.6620000000"
//            }
//          }
//        },
//        "sku": "26EZN83WFYW935BY",
//        "effectiveDate": "2021-05-01T00:00:00Z",
//        "offerTermCode": "JRTCKXETXF",
//        "termAttributes": {}
//      }
//    },
//    "Reserved": {
//      "26EZN83WFYW935BY.VJWZNREJX2": {
//        "priceDimensions": {
//          "26EZN83WFYW935BY.VJWZNREJX2.2TG2D8R56U": {
//            "unit": "Quantity",
//            "description": "Upfront Fee",
//            "rateCode": "26EZN83WFYW935BY.VJWZNREJX2.2TG2D8R56U",
//            "pricePerUnit": {
//              "USD": "4385"
//            }
//          },
//          "26EZN83WFYW935BY.VJWZNREJX2.6YS6EN2CT7": {
//            "unit": "Hrs",
//            "endRange": "Inf",
//            "description": "Red Hat Enterprise Linux (Amazon VPC), m3.2xlarge reserved instance applied",
//            "appliesTo": [],
//            "rateCode": "26EZN83WFYW935BY.VJWZNREJX2.6YS6EN2CT7",
//            "beginRange": "0",
//            "pricePerUnit": {
//              "USD": "0.0000000000"
//            }
//          }
//        },
//        "sku": "26EZN83WFYW935BY",
//        "effectiveDate": "2017-10-31T23:59:59Z",
//        "offerTermCode": "VJWZNREJX2",
//        "termAttributes": {
//          "LeaseContractLength": "1yr",
//          "OfferingClass": "convertible",
//          "PurchaseOption": "All Upfront"
//        }
//      },
//      "26EZN83WFYW935BY.NQ3QZPMQV9": {
//        "priceDimensions": {
//          "26EZN83WFYW935BY.NQ3QZPMQV9.6YS6EN2CT7": {
//            "unit": "Hrs",
//            "endRange": "Inf",
//            "description": "USD 0.0 per Red Hat Enterprise Linux (Amazon VPC), m3.2xlarge reserved instance applied",
//            "appliesTo": [],
//            "rateCode": "26EZN83WFYW935BY.NQ3QZPMQV9.6YS6EN2CT7",
//            "beginRange": "0",
//            "pricePerUnit": {
//              "USD": "0.0000000000"
//            }
//          },
//          "26EZN83WFYW935BY.NQ3QZPMQV9.2TG2D8R56U": {
//            "unit": "Quantity",
//            "description": "Upfront Fee",
//            "rateCode": "26EZN83WFYW935BY.NQ3QZPMQV9.2TG2D8R56U",
//            "pricePerUnit": {
//              "USD": "8705"
//            }
//          }
//        },
//        "sku": "26EZN83WFYW935BY",
//        "effectiveDate": "2016-09-30T23:59:59Z",
//        "offerTermCode": "NQ3QZPMQV9",
//        "termAttributes": {
//          "LeaseContractLength": "3yr",
//          "OfferingClass": "standard",
//          "PurchaseOption": "All Upfront"
//        }
//      },
//      "26EZN83WFYW935BY.Z2E3P23VKM": {
//        "priceDimensions": {
//          "26EZN83WFYW935BY.Z2E3P23VKM.6YS6EN2CT7": {
//            "unit": "Hrs",
//            "endRange": "Inf",
//            "description": "Red Hat Enterprise Linux (Amazon VPC), m3.2xlarge reserved instance applied",
//            "appliesTo": [],
//            "rateCode": "26EZN83WFYW935BY.Z2E3P23VKM.6YS6EN2CT7",
//            "beginRange": "0",
//            "pricePerUnit": {
//              "USD": "0.4720000000"
//            }
//          }
//        },
//        "sku": "26EZN83WFYW935BY",
//        "effectiveDate": "2016-09-30T23:59:59Z",
//        "offerTermCode": "Z2E3P23VKM",
//        "termAttributes": {
//          "LeaseContractLength": "3yr",
//          "OfferingClass": "convertible",
//          "PurchaseOption": "No Upfront"
//        }
//      },
//      "26EZN83WFYW935BY.MZU6U2429S": {
//        "priceDimensions": {
//          "26EZN83WFYW935BY.MZU6U2429S.6YS6EN2CT7": {
//            "unit": "Hrs",
//            "endRange": "Inf",
//            "description": "USD 0.0 per Red Hat Enterprise Linux (Amazon VPC), m3.2xlarge reserved instance applied",
//            "appliesTo": [],
//            "rateCode": "26EZN83WFYW935BY.MZU6U2429S.6YS6EN2CT7",
//            "beginRange": "0",
//            "pricePerUnit": {
//              "USD": "0.0000000000"
//            }
//          },
//          "26EZN83WFYW935BY.MZU6U2429S.2TG2D8R56U": {
//            "unit": "Quantity",
//            "description": "Upfront Fee",
//            "rateCode": "26EZN83WFYW935BY.MZU6U2429S.2TG2D8R56U",
//            "pricePerUnit": {
//              "USD": "11085"
//            }
//          }
//        },
//        "sku": "26EZN83WFYW935BY",
//        "effectiveDate": "2016-09-30T23:59:59Z",
//        "offerTermCode": "MZU6U2429S",
//        "termAttributes": {
//          "LeaseContractLength": "3yr",
//          "OfferingClass": "convertible",
//          "PurchaseOption": "All Upfront"
//        }
//      },
//      "26EZN83WFYW935BY.4NA7Y494T4": {
//        "priceDimensions": {
//          "26EZN83WFYW935BY.4NA7Y494T4.6YS6EN2CT7": {
//            "unit": "Hrs",
//            "endRange": "Inf",
//            "description": "Red Hat Enterprise Linux (Amazon VPC), m3.2xlarge reserved instance applied",
//            "appliesTo": [],
//            "rateCode": "26EZN83WFYW935BY.4NA7Y494T4.6YS6EN2CT7",
//            "beginRange": "0",
//            "pricePerUnit": {
//              "USD": "0.5100000000"
//            }
//          }
//        },
//        "sku": "26EZN83WFYW935BY",
//        "effectiveDate": "2016-09-30T23:59:59Z",
//        "offerTermCode": "4NA7Y494T4",
//        "termAttributes": {
//          "LeaseContractLength": "1yr",
//          "OfferingClass": "standard",
//          "PurchaseOption": "No Upfront"
//        }
//      },
//      "26EZN83WFYW935BY.HU7G6KETJZ": {
//        "priceDimensions": {
//          "26EZN83WFYW935BY.HU7G6KETJZ.2TG2D8R56U": {
//            "unit": "Quantity",
//            "description": "Upfront Fee",
//            "rateCode": "26EZN83WFYW935BY.HU7G6KETJZ.2TG2D8R56U",
//            "pricePerUnit": {
//              "USD": "1683"
//            }
//          },
//          "26EZN83WFYW935BY.HU7G6KETJZ.6YS6EN2CT7": {
//            "unit": "Hrs",
//            "endRange": "Inf",
//            "description": "Red Hat Enterprise Linux (Amazon VPC), m3.2xlarge reserved instance applied",
//            "appliesTo": [],
//            "rateCode": "26EZN83WFYW935BY.HU7G6KETJZ.6YS6EN2CT7",
//            "beginRange": "0",
//            "pricePerUnit": {
//              "USD": "0.2690000000"
//            }
//          }
//        },
//        "sku": "26EZN83WFYW935BY",
//        "effectiveDate": "2016-09-30T23:59:59Z",
//        "offerTermCode": "HU7G6KETJZ",
//        "termAttributes": {
//          "LeaseContractLength": "1yr",
//          "OfferingClass": "standard",
//          "PurchaseOption": "Partial Upfront"
//        }
//      },
//      "26EZN83WFYW935BY.7NE97W5U4E": {
//        "priceDimensions": {
//          "26EZN83WFYW935BY.7NE97W5U4E.6YS6EN2CT7": {
//            "unit": "Hrs",
//            "endRange": "Inf",
//            "description": "Red Hat Enterprise Linux (Amazon VPC), m3.2xlarge reserved instance applied",
//            "appliesTo": [],
//            "rateCode": "26EZN83WFYW935BY.7NE97W5U4E.6YS6EN2CT7",
//            "beginRange": "0",
//            "pricePerUnit": {
//              "USD": "0.5270000000"
//            }
//          }
//        },
//        "sku": "26EZN83WFYW935BY",
//        "effectiveDate": "2017-10-31T23:59:59Z",
//        "offerTermCode": "7NE97W5U4E",
//        "termAttributes": {
//          "LeaseContractLength": "1yr",
//          "OfferingClass": "convertible",
//          "PurchaseOption": "No Upfront"
//        }
//      },
//      "26EZN83WFYW935BY.CUZHX8X6JH": {
//        "priceDimensions": {
//          "26EZN83WFYW935BY.CUZHX8X6JH.6YS6EN2CT7": {
//            "unit": "Hrs",
//            "endRange": "Inf",
//            "description": "Red Hat Enterprise Linux (Amazon VPC), m3.2xlarge reserved instance applied",
//            "appliesTo": [],
//            "rateCode": "26EZN83WFYW935BY.CUZHX8X6JH.6YS6EN2CT7",
//            "beginRange": "0",
//            "pricePerUnit": {
//              "USD": "0.3190000000"
//            }
//          },
//          "26EZN83WFYW935BY.CUZHX8X6JH.2TG2D8R56U": {
//            "unit": "Quantity",
//            "description": "Upfront Fee",
//            "rateCode": "26EZN83WFYW935BY.CUZHX8X6JH.2TG2D8R56U",
//            "pricePerUnit": {
//              "USD": "1656"
//            }
//          }
//        },
//        "sku": "26EZN83WFYW935BY",
//        "effectiveDate": "2017-10-31T23:59:59Z",
//        "offerTermCode": "CUZHX8X6JH",
//        "termAttributes": {
//          "LeaseContractLength": "1yr",
//          "OfferingClass": "convertible",
//          "PurchaseOption": "Partial Upfront"
//        }
//      },
//      "26EZN83WFYW935BY.6QCMYABX3D": {
//        "priceDimensions": {
//          "26EZN83WFYW935BY.6QCMYABX3D.2TG2D8R56U": {
//            "unit": "Quantity",
//            "description": "Upfront Fee",
//            "rateCode": "26EZN83WFYW935BY.6QCMYABX3D.2TG2D8R56U",
//            "pricePerUnit": {
//              "USD": "3979"
//            }
//          },
//          "26EZN83WFYW935BY.6QCMYABX3D.6YS6EN2CT7": {
//            "unit": "Hrs",
//            "endRange": "Inf",
//            "description": "USD 0.0 per Red Hat Enterprise Linux (Amazon VPC), m3.2xlarge reserved instance applied",
//            "appliesTo": [],
//            "rateCode": "26EZN83WFYW935BY.6QCMYABX3D.6YS6EN2CT7",
//            "beginRange": "0",
//            "pricePerUnit": {
//              "USD": "0.0000000000"
//            }
//          }
//        },
//        "sku": "26EZN83WFYW935BY",
//        "effectiveDate": "2016-08-31T23:59:59Z",
//        "offerTermCode": "6QCMYABX3D",
//        "termAttributes": {
//          "LeaseContractLength": "1yr",
//          "OfferingClass": "standard",
//          "PurchaseOption": "All Upfront"
//        }
//      },
//      "26EZN83WFYW935BY.R5XV2EPZQZ": {
//        "priceDimensions": {
//          "26EZN83WFYW935BY.R5XV2EPZQZ.2TG2D8R56U": {
//            "unit": "Quantity",
//            "description": "Upfront Fee",
//            "rateCode": "26EZN83WFYW935BY.R5XV2EPZQZ.2TG2D8R56U",
//            "pricePerUnit": {
//              "USD": "4544"
//            }
//          },
//          "26EZN83WFYW935BY.R5XV2EPZQZ.6YS6EN2CT7": {
//            "unit": "Hrs",
//            "endRange": "Inf",
//            "description": "Red Hat Enterprise Linux (Amazon VPC), m3.2xlarge reserved instance applied",
//            "appliesTo": [],
//            "rateCode": "26EZN83WFYW935BY.R5XV2EPZQZ.6YS6EN2CT7",
//            "beginRange": "0",
//            "pricePerUnit": {
//              "USD": "0.2550000000"
//            }
//          }
//        },
//        "sku": "26EZN83WFYW935BY",
//        "effectiveDate": "2016-09-30T23:59:59Z",
//        "offerTermCode": "R5XV2EPZQZ",
//        "termAttributes": {
//          "LeaseContractLength": "3yr",
//          "OfferingClass": "convertible",
//          "PurchaseOption": "Partial Upfront"
//        }
//      },
//      "26EZN83WFYW935BY.38NPMPTW36": {
//        "priceDimensions": {
//          "26EZN83WFYW935BY.38NPMPTW36.2TG2D8R56U": {
//            "unit": "Quantity",
//            "description": "Upfront Fee",
//            "rateCode": "26EZN83WFYW935BY.38NPMPTW36.2TG2D8R56U",
//            "pricePerUnit": {
//              "USD": "2691"
//            }
//          },
//          "26EZN83WFYW935BY.38NPMPTW36.6YS6EN2CT7": {
//            "unit": "Hrs",
//            "endRange": "Inf",
//            "description": "Red Hat Enterprise Linux (Amazon VPC), m3.2xlarge reserved instance applied",
//            "appliesTo": [],
//            "rateCode": "26EZN83WFYW935BY.38NPMPTW36.6YS6EN2CT7",
//            "beginRange": "0",
//            "pricePerUnit": {
//              "USD": "0.2500000000"
//            }
//          }
//        },
//        "sku": "26EZN83WFYW935BY",
//        "effectiveDate": "2016-09-30T23:59:59Z",
//        "offerTermCode": "38NPMPTW36",
//        "termAttributes": {
//          "LeaseContractLength": "3yr",
//          "OfferingClass": "standard",
//          "PurchaseOption": "Partial Upfront"
//        }
//      }
//    }
//  },
