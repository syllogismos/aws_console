//
//  S3ObjectsView.swift
//  AWS Console
//
//  Created by Anil Karaka on 29/05/2021.
//

import SwiftUI
import SotoS3

struct S3ObjectsView: View {
    @EnvironmentObject var s3Buckets: S3Buckets
    @EnvironmentObject var spotPrice: SpotPrice
    @Environment(\.openURL) var openURL
    var bucketName: String
    @ViewBuilder
    var body: some View {
        HStack{
            HStack{
                if s3Buckets.fetchingObjects {
                    ProgressView()
                } else {
                    if s3Buckets.objects != nil{
                        List{
                            if s3Buckets.objects.commonPrefixes != nil {
                                Section(header: Text("Folders").foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)) {
                                    ForEach(s3Buckets.objects.commonPrefixes!, id: \.prefix){folder in
                                        Label(self.removePrefix(name: folder.prefix!), systemImage: "folder")
                                            .gesture(TapGesture(count: 2).onEnded {
                                                print("double clicked")
                                                s3Buckets.listObjects(bucketName: bucketName, prefix: "\(folder.prefix!)")
                                            })
                                            .contextMenu{
                                                Button(action: {s3Buckets.listObjects(bucketName: bucketName, prefix: "\(folder.prefix!)")}, label: {Text("Open")})
                                                // Disable downloading the folder
//                                                Button(action: {
//                                                        downloadFolder(bucketName: bucketName, key: folder.prefix!)
//                                                        s3Buckets.downloadFolder(bucketName: bucketName, key: folder.prefix!)}, label: {Text("Download")})
                                                //                                                Button(action: {}, label: {Text("Delete")})
                                                //                                                Button("Open in S3 Console") {
                                                //                                                    openURL(URL(string: "https://s3.console.aws.amazon.com/s3/buckets/\(bucketName)?prefix=\(folder.prefix!)")!)
                                                //                                                }
                                                
                                            }
                                    }
                                }
                            }
                            if s3Buckets.objects.contents != nil {
                                Section(header: Text("Objects").foregroundColor(.blue)){
                                    ForEach(s3Buckets.objects.contents!, id: \.key){object in
                                        S3ObjectView(object: object, name: self.removePrefix(name: object.key!))
                                            .contextMenu{
                                                Button(action: {
                                                    downloadObject(bucketName: bucketName, key: object.key!)
                                                        }, label: {Text("Download")})
                                                Button(action: {s3Buckets.deleteObject(bucketName: bucketName, key: object.key!)}, label: {Text("Delete")})
                                                Button("Open in S3 Console") {
                                                    openURL(URL(string: getEscapedURLString("https://s3.console.aws.amazon.com/s3/buckets/\(bucketName)?prefix=\(object.key!)"))!)
                                                }
                                            }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .frame(minWidth: 300)
            Spacer()
            DragDropView(bucketName: bucketName)
            
        }.onAppear(perform: {
            s3Buckets.listObjects(bucketName: bucketName, prefix: "", resetPrefixes: true)
            //            spotPrice.getSpotPriceHistory(instanceType: "p3.2xlarge")
        })
    }
    
    func removePrefix(name: String) -> String{
        return String(name.dropFirst(self.s3Buckets.prefixes.last!.count))
    }
    
    func downloadObject(bucketName: String, key: String) {
        let panel = NSSavePanel()
        panel.nameFieldLabel = "Save object as:"
        panel.nameFieldStringValue = key
        panel.canCreateDirectories = true
        panel.begin { response in
            if response == NSApplication.ModalResponse.OK, let fileUrl = panel.url {
                s3Buckets.downloadObjectStreaming(bucketName: bucketName, key: key, fileurl: fileUrl)
                print(fileUrl)
            }
        }
    }
    
    func downloadFolder(bucketName: String, key: String) {
        let panel = NSSavePanel()
        panel.nameFieldLabel = "Save object as:"
        panel.nameFieldStringValue = key
        panel.canCreateDirectories = true
        panel.begin { response in
            if response == NSApplication.ModalResponse.OK, let folderUrl = panel.url {
//                s3Buckets.downloadFolder(bucketName: bucketName, key: key, folderurl = folderUrl)
                print(folderUrl)
            }
        }
    }
    
}

struct S3ObjectView: View {
    var object: S3.Object
    var name: String
    var body: some View{
        HStack{
            Text(name)
            Spacer()
            //            Text(object.size!.description).font(.caption)
            SizeView(size: object.size!).font(.caption)
        }
    }
}

struct SizeView: View {
    var size: Int64
    var body: some View{
        if size < 1024 {
            Text("\(size) B")
        } else if size < 1024*1024 {
            Text("\(size/1024) kB")
        } else if size < 1024*1024*1024 {
            Text("\(size/(1024*1024)) MB")
        } else if size < 1024*1024*1024*1024 {
            Text("\(size/(1024*1024*1024)) GB")
        } else {
            Text("\(size) B")
        }
    }
}

//struct S3ObjectsView_Previews: PreviewProvider {
//    static var previews: some View {
//        S3ObjectsView()
//    }
//}

//ListObjectsV2Output (
//    commonPrefixes : Optional (
//        [
//            SotoS3.S3.CommonPrefix (prefix: Optional("backup/")),
//            SotoS3.S3.CommonPrefix (prefix: Optional("moengage/"))
//        ]
//    ),
//    contents : Optional (
//        [
//            SotoS3.S3.Object (
//                eTag : Optional ("\"001404e6775ff7b704ff036c2b50135a-49\""),
//                key : Optional ("dad-iphone-pics.zip"),
//                lastModified : Optional (2016-09-26 07:23:53 +0000),
//                owner : nil,
//                size : Optional (769711028),
//                storageClass : Optional (STANDARD)
//            )
//        ]
//    ),
//    continuationToken : nil,
//    delimiter : Optional ("/"),
//    encodingType : nil,
//    isTruncated : Optional (false),
//    keyCount : Optional (3),
//    maxKeys : Optional (1000),
//    name : Optional ("anil-s3"),
//    nextContinuationToken : nil,
//    prefix : Optional (""),
//    startAfter : nil
//)

