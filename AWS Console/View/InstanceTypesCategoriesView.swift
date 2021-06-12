////
////  InstanceTypesCategoriesView.swift
////  AWS Console
////
////  Created by Anil Karaka on 02/06/2021.
////
//
//import SwiftUI
//
//struct InstanceTypesCategoriesView: View {
//
//
//    var generalPurpose: [String]
//    var computeOptimized: [String]
//    var acceleratedCompute: [String]
//    var memoryOptimized: [String]
//    var storageOptimized: [String]
//
//    var body: some View {
//        CategoriesView(categories: [
//            Category(id: "generalPurpose", name: "General Purpose", value: generalPurpose),
//            Category(id: "computeOptimized", name: "Compute Optimized", value: computeOptimized),
//            Category(id: "acceleratedCompute", name: "Accelerated Compute", value: acceleratedCompute),
//            Category(id: "memoryOptimized", name: "Memory Optimized", value: memoryOptimized),
//            Category(id: "storageOptimized", name: "Storage Optimized", value: storageOptimized)
//        ])
//    }
//}
//
//struct CategoriesView: View {
//    @EnvironmentObject var instanceTypes: InstanceTypes
//    @EnvironmentObject var userPreferences: UserPreferences
//
//    @State private var isLoading = false
//    @State private var categorySelection = "General Purpose"
//
//    //    private var categories = ["generalPurpose", "computeOptimized", "acceleratedCompute", "memoryOptimized", "storageOptimized"]
//
//    //    var generalPurpose: [String]
//    //    var computeOptimized: [String]
//    //    var acceleratedCompute: [String]
//    //    var memoryOptimized: [String]
//    //    var storageOptimized: [String]
//
//    var categories: [Category]
//
//    var body: some View {
////        List(categories.map({$0.name}), id: \.self, selection: $categorySelection){categoryName in
////            Text(categoryName)
////        }
//        List(selection: $categorySelection, content: {
//            ForEach(categories.map({$0.name}), id:\.self) {
//                                Text($0)
//                            }
//                        })
//    }
//}
//
//struct Category {
//    let id: String
//    let name: String
//    let value: [String]
//}
//
//struct InstanceTypeList: View {
//    var types: [String]
//    var body: some View {
//        List{
//            ForEach(types, id: \.self){type in
//                NavigationLink(destination: InstanceTypeView(type: type), label: {Text(type)})
//            }
//        }
//    }
//}
//
//struct InstanceTypesCategoriesView_Previews: PreviewProvider {
//    static var previews: some View {
//        InstanceTypesCategoriesView(generalPurpose: ["anil"], computeOptimized: ["anil"], acceleratedCompute: ["anil"], memoryOptimized: ["anil"], storageOptimized: ["anil"])
//    }
//}
