//
//  InstancesHelper.swift
//  AWS Console
//
//  Created by Anil Karaka on 13/08/21.
//

import Foundation
import SotoEC2


func getNameOfInstanceFromTags(instance: EC2.Instance) -> String {
    if instance.tags?.count == 0 {
        return instance.instanceId ?? ""
    }
    else {
        let nametags = instance.tags!.filter{(tag) -> Bool in return tag.key!.lowercased() == "name"}
        if nametags.count == 0 {
            return instance.instanceId ?? ""
        }
        return nametags.first!.value ?? instance.instanceId!
    }
    
}
