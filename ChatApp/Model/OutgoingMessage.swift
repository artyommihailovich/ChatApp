//
//  OutgoingMessage.swift
//  ChatApp
//
//  Created by Artyom Mihailovich on 12/1/20.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift
import Gallery

class OutgoingMessage {
    class func send(chatId: String, text: String?, photo: UIImage?, video: Video?, audio: String?, audioDuration: Float = 0.0, location: String?, memberIds: [String]) {
        
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
        
        if photo != nil {
            sendPictureMessage(message: message, photo: photo!, memberIds: memberIds)
        }
        
        if video != nil {
            sendVideoMessage(message: message, video: video!, memberIds: memberIds)
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


    //MARK: -  Sending messages with different data types

func sendTextMessage(message: LocalMessage, text: String, memberIds: [String]) {
    message.message = text
    message.type = kTEXT
    
    OutgoingMessage.sendMessage(message: message, memberIds: memberIds)
    
}

func sendPictureMessage(message: LocalMessage, photo: UIImage, memberIds: [String]) {
    message.message = "Picture message"
    message.type = kPHOTO
    
    let fileName = Date().stringDate()
    let fileDirectory = "MediaMessages/Photo/" + "(\(message.chatRoomId)/" + "_\(fileName)" + ".jpg"
    
    FileStorage.saveFileLocally(fileData: photo.jpegData(compressionQuality: 0.7)! as NSData, fileName: fileName)
    
    FileStorage.uploadImage(photo , directory: fileDirectory) { (imageURL) in
        
        if  imageURL != nil {
            message.pictureUrl = imageURL ?? ""
            
            OutgoingMessage.sendMessage(message: message, memberIds: memberIds)
        }
    }
}

func sendVideoMessage(message: LocalMessage, video: Video, memberIds: [String]) {
    message.message = "Video message"
    message.type = kVIDEO
    
    let fileName = Date().stringDate()
    let thumbnailDirectory = "MediaMessages/Photo/" + "(\(message.chatRoomId)/" + "_\(fileName)" + ".jpg"
    let videoDirectory = "MediaMessages/Video/" + "(\(message.chatRoomId)/" + "_\(fileName)" + ".mov"
    
    let editor = VideoEditor()
    editor.process(video: video) { (proccesedVideo, videoUrl) in
       
        if let tempPath = videoUrl {
            let thumbnail = videoThumbnail(video: tempPath)
            
            FileStorage.saveFileLocally(fileData: thumbnail.jpegData(compressionQuality: 0.8)! as NSData, fileName: fileName)
            
            FileStorage.uploadImage(thumbnail, directory: thumbnailDirectory) { (imageLink) in
                
                if imageLink != nil {
                    let videoData = NSData(contentsOfFile: tempPath.path)
                    
                    FileStorage.saveFileLocally(fileData: videoData!, fileName: fileName + ".mov")
                    FileStorage.uploadVideo(videoData!, directory: videoDirectory) { (videoLink) in
                        message.pictureUrl = imageLink ?? ""
                        message.videoUrl = videoLink ?? ""
                        
                        OutgoingMessage.sendMessage(message: message, memberIds: memberIds)
                    }
                }
            }
        }
    }
}
