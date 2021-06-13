//
//  BucketsView.swift
//  AWS Console
//
//  Created by Anil Karaka on 27/05/2021.
//

import SwiftUI

struct BucketsView: View {
    @EnvironmentObject var s3Buckets: S3Buckets
    @EnvironmentObject var userPreferences: UserPreferences
    
    var body: some View {
        List(self.s3Buckets.buckets, id: \.name){bucket in
            NavigationLink(
                destination: S3ObjectsView(bucketName: bucket.name ?? ""), label: {Text(bucket.name ?? "")}
            )
        }
        .navigationTitle("S3 Buckets: \(s3Buckets.currentBucket)/\(s3Buckets.prefixes.last!)")
        .toolbar{
            Button(action: {
                self.s3Buckets.goBackOneFolder()
            }){
                Image(systemName: "chevron.backward")
            }
            Button(action: {s3Buckets.getS3Buckets()}){
                Image(systemName: "arrow.clockwise")
            }
        }
    }
}

struct BucketsView_Previews: PreviewProvider {
    static var previews: some View {
        BucketsView()
            .environmentObject(UserPreferences())
            .environmentObject(S3Buckets())
    }
}
