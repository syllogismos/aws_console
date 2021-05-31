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
    var body: some View {
        VStack {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        }.onAppear(perform: {
            instanceTypes.getInstanceTypeDetails(type: type)
//            instanceTypes.getSpotPriceHistory(type: type)
            instanceTypes.getPricingDetails(type: type)
        })
    }
}

struct InstanceTypeView_Previews: PreviewProvider {
    static var previews: some View {
        InstanceTypeView(type: "p2.2xlarge")
            .environmentObject(InstanceTypes())
    }
}
