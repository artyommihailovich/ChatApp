//
//  OutgoingMessage.swift
//  ChatApp
//
//  Created by Artyom Mihailovich on 12/1/20.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class OutgoingMessage {
    class func send(chatId: String, text: String?, photo: UIImage?, video: String?, audio: String?, audioDuration: Float = 0.0, location: String?, memberIds: [String]) {
        
        let currentUser = User.currentUser!
        
        let message = LocalMessage()
        message.id = UUID().uuidString
        message.chatRoomId = chatId
        message.senderId = currentUser.id
        message.senderName = currentUser.username
        message.senderInitials = String(currentUser.username.first!)
        message.date = Date()
        message.status = kSENT
        
        if text != nil {
            //Send text message
            sendTextMessage(message: message, text: text!, memberIds: memberIds)
        }
        
        FirebaseRecentListener.shared.updateRecents(chatRoomid: chatId, lastMessage: message.message)
    }
    
    class func sendMessage(message: LocalMessage, memberIds: [String]) {
        
        RealmManager.shared.saveToRealm(message)
        
        for memberId in memberIds {
            FirebaseMessageListener.shared.addMessage(message, memberId: memberId)
        }
    }
}


func sendTextMessage(message: LocalMessage, text: String, memberIds: [String]) {
    message.message = text
    message.type = kTEXT
    
    OutgoingMessage.sendMessage(message: message, memberIds: memberIds)
    
}
