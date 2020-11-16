//
//  LocalMessage.swift
//  ChatApp
//
//  Created by Artyom Mihailovich on 11/16/20.
//

import Foundation
import RealmSwift

class LocalMessage: Object, Codable {
    @objc dynamic var id = ""
    @objc dynamic var chatRoomId = ""
    @objc dynamic var date = Date()
    @objc dynamic var senderName = ""
    @objc dynamic var senderId = ""
    @objc dynamic var senderInitials = ""
    @objc dynamic var readDate = Date()
    @objc dynamic var type = ""
    @objc dynamic var status = ""
    @objc dynamic var message = ""
    @objc dynamic var audioUrl = ""
    @objc dynamic var videoUrl = ""
    @objc dynamic var pictureUrl = ""
    @objc dynamic var latitude = 0.0
    @objc dynamic var longitude = 0.0
    @objc dynamic var audioDuration = 0.0
    
    override class func primaryKey() -> String? {
        return "id"
    }
}


