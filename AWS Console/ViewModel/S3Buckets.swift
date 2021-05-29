//
//  S3Buckets.swift
//  AWS Console
//
//  Created by Anil Karaka on 27/05/2021.
//

import Foundation
import SotoS3
import Combine

class S3Buckets: ObservableObject{
    @Published var buckets = [S3.Bucket]()
    @Published var objects: S3.ListObjectsV2Output!
    
    private var accessKey: String
    private var secretKey: String
    
    func refreshKeys() {
        self.accessKey = UserDefaults.standard.object(forKey: "accessKey") as? String ?? ""
        
        self.secretKey = UserDefaults.standard.object(forKey: "secretKey") as? String ?? ""
        
    }
    
    init() {
        self.accessKey = UserDefaults.standard.object(forKey: "accessKey") as? String ?? ""
        self.secretKey = UserDefaults.standard.object(forKey: "secretKey") as? String ?? ""
        self.objects = nil
        self.getS3Buckets()
    }
    
    func getS3Buckets() {
        print("Getting S3 Buckets")
        refreshKeys()
        let client = AWSClient(credentialProvider: .static(accessKeyId: self.accessKey, secretAccessKey: self.secretKey), httpClientProvider: .createNew)
        
        print(client)
        
        let shutdown = {
            [client] in
            do {
                try client.syncShutdown()
            } catch {
                print("client shutdown error deinit in s3buckets")
            }
        }
        
        let s3 = S3(client: client)
        
        s3.listBuckets()
            .whenComplete { response in
                switch response {
                case .failure(let error):
                    print(error)
                    print("Failure S3")
                    shutdown()
                    self.buckets = []
                case .success(let output):
                    DispatchQueue.main.async { // published updates should be on the main thread
//                        print(output)
                        print("Success S3")
                        self.buckets = output.buckets ?? []
//                        print(self.buckets)
                        print(self.buckets.count)
                        print("number of buckets")
                    }
                    shutdown()
                }
            }
    }
    
    func listObjects(bucketName: String){
        print("Getting objects in the bucket \(bucketName)")
        refreshKeys()
        let client = AWSClient(credentialProvider: .static(accessKeyId: self.accessKey, secretAccessKey: self.secretKey), httpClientProvider: .createNew)
        
        let shutdown = {
            [client] in
            do {
                try client.syncShutdown()
            } catch {
                print("client shutdown error deinit listobjects")
            }
        }
        
        let s3 = S3(client: client)
        let request = S3.ListObjectsV2Request(bucket: bucketName, delimiter: "/")
        s3.listObjectsV2(request)
            .whenComplete{ response in
                switch response {
                case .failure(let error):
                    print(error)
                    print("Failure listObjectsv2")
                    shutdown()
//                    objects = nil
                case .success(let output):
                    DispatchQueue.main.async {
//                        let objects = output.contents
                        print(output)
                        print("TTTTTTTTTTTTTTTTTT")
                        shutdown()
                        self.objects = output
                    }
                }
            }
        return
    }
}