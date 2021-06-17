//
//  BucketView.swift
//  AWS Console
//
//  Created by Anil Karaka on 27/05/2021.
//

import SwiftUI

struct DragDropView: View {
    @State var image = NSImage(named: "image")
    var bucketName: String
    //    var listObjects: () -> ()
    var body: some View {
        //        VStack {
        //            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        //                .onTapGesture {
        //                    listObjects()
        //                }
        InputView(image: $image, bucketName: self.bucketName)
            .padding()
        //        }
    }
}

//struct BucketView_Previews: PreviewProvider {
//    static var previews: some View {
//        BucketView()
//    }
//}

struct InputView: View {
    
    @Binding var image: NSImage?
    var bucketName: String
    @EnvironmentObject var s3Buckets: S3Buckets
    
    var body: some View {
        VStack(spacing: 16) {
            //            HStack {
            //                Text("Input Image (PNG,JPG,JPEG,HEIC)")
            //                Button(action: selectFile) {
            //                    Text("From Finder")
            //                }
            //            }
            InputImageView(image: self.$image, bucketName: self.bucketName)
            ForEach(Array(s3Buckets.uploadProgressFiles.keys), id: \.self){key in
                ProgressView(key, value: s3Buckets.uploadProgressFiles[key], total: 1)
            }
//            ProgressView("Upload", value: s3Buckets.uploadProgress, total: 1)
        }
    }
    
    private func selectFile() {
        NSOpenPanel.openImage { (result) in
            if case let .success(image) = result {
                self.image = image
            }
        }
    }
}

struct InputImageView: View {
    @EnvironmentObject var s3Buckets: S3Buckets

    @Binding var image: NSImage?
    var bucketName: String
    
    var body: some View {
        ZStack {
            if self.image != nil {
                Image(nsImage: self.image!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Text("Drop files/folders here to upload to S3")
                    .frame(width: 320)
            }
        }
        .frame(height: 320)
        .background(Color.black.opacity(0.5))
        .cornerRadius(8)
        
        .onDrop(of: ["public.url","public.file-url"], isTargeted: nil) { (items) -> Bool in
            if let item = items.first {
                if let identifier = item.registeredTypeIdentifiers.first {
                    print("onDrop with identifier = \(identifier)")
                    if identifier == "public.url" || identifier == "public.file-url" {
                        item.loadItem(forTypeIdentifier: identifier, options: nil) { (urlData, error) in
//                            DispatchQueue.main.async {
//                                if let urlData = urlData as? Data {
//                                    let urll = NSURL(absoluteURLWithDataRepresentation: urlData, relativeTo: nil) as URL
//                                    if let img = NSImage(contentsOf: urll) {
//                                        self.image = img
//                                        print("got it")
//                                    }
//                                }
//                            }
//                            let home = FileManager.default.homeDirectoryForCurrentUser
//
//                            let movPath = "Desktop/AWS Console.mov"
//
//                            let movUrl = home.appendingPathComponent(movPath)
                            let prefix = s3Buckets.prefixes.last
                            if let urlData = urlData as? Data {
                                let urll = NSURL(absoluteURLWithDataRepresentation: urlData, relativeTo: nil) as URL
                                let key = prefix != "" ? "\(prefix ?? "")\(urll.lastPathComponent)" : urll.lastPathComponent
                                

                                s3Buckets.uploadObject(bucketName: self.bucketName, key: key, fileURL: urll)
                            }
                        }
                    }
                }
                return true
            } else { print("item not here"); return false }
        }
    }
}


extension NSOpenPanel {
    
    static func openImage(completion: @escaping (_ result: Result<NSImage, Error>) -> ()) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowedFileTypes = ["jpg", "jpeg", "png", "heic"]
        panel.canChooseFiles = true
        panel.begin { (result) in
            if result == .OK,
               let url = panel.urls.first,
               let image = NSImage(contentsOf: url) {
                completion(.success(image))
            } else {
                completion(.failure(
                    NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to get file location"])
                ))
            }
        }
    }
}
