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
    @Published var prefixes = [""]
    @Published var fetchingObjects = false
    @Published var currentBucket = ""
    
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
    
    func goBackOneFolder(){
        if self.currentBucket != "" && self.prefixes.count > 1{
            print(self.prefixes)
            _ = self.prefixes.popLast()
            self.listObjects(bucketName: self.currentBucket, prefix: self.prefixes.last!, goingBack: true)
        }
    }
    
    func listObjects(bucketName: String, prefix: String, resetPrefixes: Bool = false, goingBack: Bool = false){
        self.currentBucket = bucketName
        self.fetchingObjects = true
        if !goingBack{
            if resetPrefixes{
                self.prefixes = [""]
            } else {
                self.prefixes.append(prefix)
            }
        }
        print(self.prefixes)
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
        let request = S3.ListObjectsV2Request(bucket: bucketName, delimiter: "/", prefix: self.prefixes.last)
        s3.listObjectsV2(request)
            .whenComplete{ response in
                switch response {
                case .failure(let error):
                    print(error)
                    print("Failure listObjectsv2")
                    DispatchQueue.main.async {
                        self.fetchingObjects = false
                    }
                    shutdown()
                //                    objects = nil
                case .success(let output):
                    DispatchQueue.main.async {
                        //                        let objects = output.contents
                        //                        print(output)
                        //                        print("TTTTTTTTTTTTTTTTTT")
                        self.fetchingObjects = false
                        shutdown()
                        self.objects = output
                    }
                }
            }
        return
    }
    
    func deleteObject(bucketName: String, key: String){
        print("deleting the object \(key) in bucket \(bucketName)")
        refreshKeys()
        let client = AWSClient(credentialProvider: .static(accessKeyId: self.accessKey, secretAccessKey: self.secretKey), httpClientProvider: .createNew)
        
        let shutdown = {
            [client] in
            do {
                try client.syncShutdown()
            } catch {
                print("client shutdown failed in deleteObject func")
            }
        }
        
        let s3 = S3(client: client)
        let request = S3.DeleteObjectRequest(bucket: bucketName, key: key)
        s3.deleteObject(request)
            .whenComplete{ response in
                switch response {
                case .failure(let error):
                    print(error)
                    print("Failure deleteObject")
                    shutdown()
                case .success(let output):
                    DispatchQueue.main.async{
                        shutdown()
                        print(output)
                        print("EEEEEEEEEEEEEEEEEEEEEEEEEEE")
                    }
                }
            }
        return
    }
    
    func downloadObject(bucketName: String, key: String){
        print("downloading the object \(key) in bucket \(bucketName)")
        refreshKeys()
        
        let client = AWSClient(credentialProvider: .static(accessKeyId: self.accessKey, secretAccessKey: self.secretKey), httpClientProvider: .createNew)
        
        let shutdown = {
            [client] in
            do {
                try client.syncShutdown()
            } catch {
                print("client shutdown failed in downloadObject func")
            }
        }
        
        let s3 = S3(client: client)
        let request = S3.GetObjectRequest(bucket: bucketName, key: key)
        s3.getObject(request)
            .whenComplete{response in
                switch response {
                case .failure(let error):
                    print(error)
                    print("failure get object")
                    shutdown()
                case .success(let output):
                    print(output)
                    writeToFile(data: (output.body?.asData())!, fileName: key)
                    print("00000000000000000000000000")
                    shutdown()
                }
            }
        return
    }
    
    func downloadObjectStreaming(bucketName: String, key: String){
        // TODO: fix filename when you get it from the key, only take the last
        // part of the key after /
        print("streaming the object \(key) in bucktet \(bucketName)")
        refreshKeys()
        
        let client = AWSClient(credentialProvider: .static(accessKeyId: self.accessKey, secretAccessKey: self.secretKey), httpClientProvider: .createNew)
        
        let shutdown = {
            [client] in
            do {
                try client.syncShutdown()
            } catch {
                print("client shutdown failed in downloadobjectstreaming func")
            }
        }
        
        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last else {
            return
        }
        
        let fileurl = directory.appendingPathComponent(key)
        print(fileurl.absoluteString)
        
        if FileManager.default.fileExists(atPath: fileurl.path) {
            print("file already exists")
            do {
                print("deleting file \(fileurl.path)")
                try FileManager.default.removeItem(atPath: fileurl.path)
            } catch {
                print("unable to delete existing file")
            }
        }
        
        FileManager.default.createFile(atPath: fileurl.path, contents: nil)
        let fileHandle = FileHandle(forWritingAtPath: fileurl.path)
        fileHandle?.seekToEndOfFile()
        
        let s3 = S3(client: client)
        let request = S3.GetObjectRequest(bucket: bucketName, key: key)
        s3.getObjectStreaming(request){ bytebuffer, eventloop in
//            print(bytebuffer)
//            print("bbbbbbbbbbbbbbbbbbbbbbbbbb")
            fileHandle?.write(bytebuffer.getData(at: 0, length: bytebuffer.capacity)!)
            return eventloop.makeSucceededFuture(())
        }.whenComplete{ response in
            switch response {
            case .failure(let error):
                print(error)
                print("error in streaming download func")
                shutdown()
            case .success(let output):
                print(output)
                print("success streaming")
                shutdown()
            }
        }
    }
}

func writeToFile(data: Data, fileName: String){
    // get path of directory
    guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last else {
        return
    }
    // create file url
    let fileurl =  directory.appendingPathComponent(fileName)
    print(fileurl.absoluteString)
// if file exists then write data
    if FileManager.default.fileExists(atPath: fileurl.path) {
        if let fileHandle = FileHandle(forWritingAtPath: fileurl.path) {
            // seekToEndOfFile, writes data at the last of file(appends not override)
            fileHandle.seekToEndOfFile()
            fileHandle.write(data)
            fileHandle.closeFile()
        }
        else {
            print("Can't open file to write.")
        }
    }
    else {
        // if file does not exist write data for the first time
        do{
            try data.write(to: fileurl, options: .atomic)
        }catch {
            print("Unable to write in new file.")
        }
    }

}
