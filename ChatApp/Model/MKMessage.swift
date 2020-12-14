//
//  MKMessage.swift
//  ChatApp
//
//  Created by Artyom Mihailovich on 11/16/20.
//

import Foundation
import MessageKit
import CoreLocation

class MKMessage: NSObject, MessageType {
    
    //MARK: - Variables
    
    var messageId: String = ""
    
    var kind: MessageKind
    var sentDate: Date
    var incoming: Bool

    var mkSender: MKSender
    var sender: SenderType { return mkSender }
    var senderInitials: String
    
    var photoItem: PhotoMessage?
    
    var status: String
    var readDate: Date
    
    
    //MARK: - Init

    init(message: LocalMessage) {
        self.messageId = message.id
        self.mkSender = MKSender(senderId: message.senderId, displayName: message.senderName)
        self.status = message.status
        self.kind = MessageKind.text(message.message)
        
        switch message.type {
        case kTEXT:
            self.kind = MessageKind.text(message.message)
        case kPHOTO:
            let photoItem  = PhotoMessage(path: message.pictureUrl)
            
            self.kind = MessageKind.photo(photoItem)
            self.photoItem = photoItem
        default:
            print("Unknow message type")
        }
        
        self.senderInitials = message.senderInitials
        self.sentDate = message.date
        self.readDate  = message.readDate
        self.incoming = User.currentId != mkSender.senderId
    }
}
