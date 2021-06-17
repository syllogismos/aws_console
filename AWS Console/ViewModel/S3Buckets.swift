//
//  S3Buckets.swift
//  AWS Console
//
//  Created by Anil Karaka on 27/05/2021.
//

import Foundation
import SotoS3
import Combine
import NIOFoundationCompat
import NIO
import SotoS3FileTransfer

class S3Buckets: ObservableObject{
    @Published var buckets = [S3.Bucket]()
    @Published var objects: S3.ListObjectsV2Output!
    @Published var prefixes = [""]
    @Published var fetchingObjects = false
    @Published var currentBucket = ""
    @Published var uploadProgressFiles = [String: Double]()
    
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
                        self.objects = nil
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
    
    
//    func uploadObjectStreaming(bucketName: String, key: String, fileURL: URL){
//        print("stream upload the file \(fileURL.absoluteString) to the bucket \(bucketName), with key \(key)")
//        refreshKeys()
//
//
//
//        if !FileManager.default.fileExists(atPath: fileURL.path) {
//            return
//        }
//
//        let client = AWSClient(credentialProvider: .static(accessKeyId: self.accessKey, secretAccessKey: self.secretKey), httpClientProvider: .createNew)
//
//        let shutdown = {
//            [client] in
//            do {
//                try client.syncShutdown()
//            } catch {
//                print("client shutdown failed in uploadObjectStreaming")
//            }
//        }
//        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last else {
//            return
//        }
//
//        let movPath = "AWS Console.mov"
//
//        let movUrl = directory.appendingPathComponent(movPath)
//        let fileHandle = FileHandle(forReadingAtPath: movUrl.path)
//        do {
//            let handle = try FileHandle(forReadingFrom: movUrl)
//        } catch let error as NSError{
//            print("error at handle: \(error)")
//        }
//        //        let niohandle: NIOFileHandle
//        //        do {
//        //            niohandle = try NIOFileHandle(path: movUrl.path)
//        //        } catch let error as NSError {
//        //            print("error at niohandle: \(error)")
//        //        }
//        var fileSize: UInt64 = 0
//        do {
//            let attr = try FileManager.default.attributesOfItem(atPath: movUrl.path)
//            fileSize = attr[FileAttributeKey.size] as! UInt64
//        } catch let error as NSError {
//            print("error while getting size \(error)")
//        }
//        print(movUrl.path)
//        if !FileManager.default.fileExists(atPath: movUrl.path) {
//            print("file odesnt exist")
//        } else {
//            print("file exists")
//        }
//        do { try fileHandle?.seek(toOffset: 0)} catch {}
//
//        var offset: UInt64 = 0
//        let size = 1024
//        let data = fileHandle?.readData(ofLength: size)
//        print(data as Any)
//        print("outside")
//
//        let s3 = S3(client: client)
//
//        //        let payload = AWSPayload.stream(size: size){ eventloop in
//        //            let data = fileHandle?.readData(ofLength: size)
//        //            offset += UInt64(size)
//        //            do {try fileHandle?.seek(toOffset: offset)} catch {}
//        //            print(data as Any)
//        //            let buffer = ByteBufferAllocator().buffer(data: data!)
//        //            if data == nil{
//        //                print("end")
//        //                return eventloop.makeSucceededFuture(.end)
//        //            }
//        //            print("not end")
//        //            return eventloop.makeSucceededFuture(.byteBuffer(buffer))
//        //        }
//        //        let request = S3.PutObjectRequest(body: payload, bucket: "anil-temp", key: "AWS Console.mov")
//        let threadpool = NIOThreadPool(numberOfThreads: 4)
//        threadpool.start()
//        let nonBlockFileIO = NonBlockingFileIO(threadPool: threadpool)
//
//
//
//        do {
//            let niohandle = try NIOFileHandle(path: movUrl.path)
//
//            let fileclose = {
//                [niohandle] in
//                do {
//                    try niohandle.close()
//                } catch {
//                    print("nio handle close")
//                }
//            }
//
//            let request = S3.PutObjectRequest(
//                body: .fileHandle(niohandle, size: Int(fileSize), fileIO: nonBlockFileIO),
//                bucket: "anil-temp",
//                key: "dragdrop"
//            )
//            s3.putObject(request)
//                .whenComplete{ response in
//                    print(response)
//                    switch response {
//                    case .failure(let error):
//                        print(error)
//                        print("error in streaming upload func")
//                        shutdown()
//                        fileclose()
//                    case .success(let output):
//                        print(output)
//                        print("success streaming upload")
//                        shutdown()
//                        fileclose()
//                    }
//                }
//        } catch let error as NSError {
//            print("error at niohandle: \(error)")
//        }
//
//
//
//
//    }
    
    func downloadFolder(bucketName: String, key: String){
        print("downloading the folder \(key) from bucket \(bucketName) using s3filetransfermanager")
        refreshKeys()
        let client = AWSClient(credentialProvider: .static(accessKeyId: self.accessKey, secretAccessKey: self.secretKey), httpClientProvider: .createNew)
        
        let s3 = S3(client: client)
        let s3FileTransferManager = S3FileTransferManager(s3: s3, threadPoolProvider: .createNew)
        
        let shutdown = {
            [client] in
            do {
                try client.syncShutdown()
            } catch {
                print("client shutdown failed in downloadobjecttransfermanager func")
            }
        }
        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last else {
            return
        }
        let folderurl = directory.appendingPathComponent(key)
        print(folderurl.absoluteString)
        
        if FileManager.default.fileExists(atPath: folderurl.path){
            print("folder already exists")
            do {
                print("deleting folder \(folderurl.path)")
                try FileManager.default.removeItem(atPath: folderurl.path)
            } catch {
                print("unable to delete existing folder")
            }
        }
        s3FileTransferManager.copy(
            from: S3Folder(url: "s3://\(bucketName)/\(key)")!,
            to: folderurl.path
        ).whenComplete{response in
            switch response {
            case .failure(let error):
                print(error)
                print("rror while downloading folder")
                shutdown()
            case .success(let output):
                print(output)
                print("downloading folder succeeded")
                shutdown()
            }
        }
        
        
    }
    
    func uploadObject(bucketName: String, key: String, fileURL: URL){
        print("uploading the file \(fileURL.absoluteString) to the bucket \(bucketName) with key \(key)")
        let progressKey = "\(bucketName)/\(key)"
        DispatchQueue.main.async {
            self.uploadProgressFiles[progressKey] = 0.0
        }
        
        refreshKeys()
        
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            return
        }
        
        let client = AWSClient(credentialProvider: .static(accessKeyId: self.accessKey, secretAccessKey: self.secretKey), httpClientProvider: .createNew)
        
        let s3 = S3(client: client)
        let s3FileTransferManager = S3FileTransferManager(s3: s3, threadPoolProvider: .createNew)
        
        let shutdown = {
            [client] in
            do {
                try client.syncShutdown()
            } catch {
                print("client shutdown failed in upload object")
            }
        }
        
        //        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last else {
        //            return
        //        }
        //
        //        let movPath = "AWS Console.mov"
        //        let movURL = directory.appendingPathComponent(movPath)
        if fileURL.hasDirectoryPath {
            s3FileTransferManager.copy(
                from: fileURL.path,
                to: S3Folder(url: "s3://\(bucketName)/\(key)")!
            ).whenComplete{response in
                print(response)
                switch response {
                case .failure(let error):
                    print(error)
                    shutdown()
                case .success(let output):
                    print(output)
                    shutdown()
                }
            }
        } else {
            s3FileTransferManager.copy(
                from: fileURL.path,
                to: S3File(url: "s3://\(bucketName)/\(key)")!,
                progress: {p in
//                    print("progress \(p)")
                    DispatchQueue.main.async {
                        self.uploadProgressFiles[progressKey] = p
                    }
                }
            ).whenComplete{response in
                print(response)
                DispatchQueue.main.async {
                    self.uploadProgressFiles.removeValue(forKey: progressKey)
                }
                switch response {
                case .failure(let error):
                    print(error)
                    shutdown()
                case .success(let output):
                    print(output)
                    shutdown()
                }
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
