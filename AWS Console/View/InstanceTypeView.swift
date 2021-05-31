//
//  InstanceTypeView.swift
//  AWS Console
//
//  Created by Anil Karaka on 31/05/2021.
//

import SwiftUI

struct InstanceTypeView: View {
    @EnvironmentObject var instanceTypes: InstanceTypes
    var type: String
    @ViewBuilder
    var body: some View {
        VStack {
            Text("Instance Details: \(type)")
                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                .foregroundColor(.secondary)
            HStack {
                
                if (instanceTypes.pricingDetails != nil) {
                    VStack {
                        Text("On Demand Price")
                        Text((instanceTypes.pricingDetails!.terms.OnDemand.values.first?.priceDimensions.values.first?.pricePerUnit.USD)!)
                    }
                    .padding()
                    .foregroundColor(.green)
                    .border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
                } else {
                    Text("Querying Price")
                }
                if (instanceTypes.spotPriceHistory != nil) {
                    HStack{
                        ForEach(Array(Set(instanceTypes.spotPriceHistory!.map({$0.availabilityZone!}))), id:\.self){zone in
                            VStack {
                                Text(zone)
                                Text(instanceTypes.spotPriceHistory!.filter({$0.availabilityZone! == zone}).first!.spotPrice!)
                            }
                            .padding()
                            .foregroundColor(.red)
                            .border(Color.black, width: 1)
                        }
                    }
                } else {
                    Text("Querying Spot Price")
                }
                
            }
            if instanceTypes.instanceTypeDetails != nil {
                HStack {
                    VStack(alignment: .leading) {
                        ClickToCopy(title: "vcpu", text: instanceTypes.instanceTypeDetails!.vCpuInfo!.defaultVCpus!.description, clickToCopy: false)
                        ClickToCopy(title: "Memory", text: instanceTypes.instanceTypeDetails!.memoryInfo!.sizeInMiB!.description, clickToCopy: false)
                    }
                    Spacer()
                }.padding()
            } else {
                Text("Instance Type Details")
            }
            Spacer()

            
        }
        .padding(.top)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear(perform: {
            instanceTypes.getInstanceTypeDetails(type: type)
            instanceTypes.getSpotPriceHistory(type: type)
            instanceTypes.getPricingDetails(type: type)
        })
    }
}

struct InstanceTypeView_Previews: PreviewProvider {
    static var previews: some View {
        InstanceTypeView(type: "p3.2xlarge")
            .environmentObject(InstanceTypes())
    }
}
