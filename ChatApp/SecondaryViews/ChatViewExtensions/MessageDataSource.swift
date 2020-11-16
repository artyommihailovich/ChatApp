//
//  MessageDataSource.swift
//  ChatApp
//
//  Created by Artyom Mihailovich on 11/15/20.
//

import Foundation
import MessageKit

extension ChatViewController: MessagesDataSource {
    
    func currentSender() -> SenderType {
        return currentUser
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
       
        return mkMessages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        
        return mkMessages.count
    }
}
