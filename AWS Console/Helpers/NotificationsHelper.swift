//
//  NotificationsHelper.swift
//  AWS Console
//
//  Created by Anil Karaka on 18/06/2021.
//

import Foundation

import UserNotifications


func sendUserNotification(title: String, subtitle: String){
    let content = UNMutableNotificationContent()
    content.title = title
    content.subtitle = subtitle
    content.sound = UNNotificationSound.default

    // show this notification five seconds from now
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)

    // choose a random identifier
    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

    // add our notification request
    UNUserNotificationCenter.current().add(request)

}

