//
//  UserPreferences.swift
//  AWS Console
//
//  Created by Anil Karaka on 26/05/2021.
//

import Foundation
import Combine
import SotoS3

class UserPreferences: ObservableObject{
    @Published var accessKey: String{
        didSet {
            UserDefaults.standard.set(accessKey, forKey: "accessKey")
        }
    }
    
    @Published var secretKey: String{
        didSet{
            UserDefaults.standard.set(secretKey, forKey: "secretKey")
        }
    }
    
    @Published var region: String {
        didSet {
            UserDefaults.standard.set(region, forKey: "region")
        }
    }
    
    @Published var os: OperatingSystem{
        didSet {
            UserDefaults.standard.set(os, forKey: "os")
        }
    }
    
    @Published var sidebarSelection: String? {
        didSet {
            UserDefaults.standard.set(sidebarSelection, forKey: "sidebarSelection")
        }
    }
        
    init() {
        self.accessKey = UserDefaults.standard.object(forKey: "accessKey") as? String ?? ""
        self.secretKey = UserDefaults.standard.object(forKey: "secretKey") as? String ?? ""
        self.region = UserDefaults.standard.object(forKey: "region") as? String ?? "us-east-1"
        self.os = UserDefaults.standard.object(forKey: "os") as? OperatingSystem ?? LinuxOS
        self.sidebarSelection = UserDefaults.standard.object(forKey: "sidebarSelection") as? String ?? "Settings"
    }
}
