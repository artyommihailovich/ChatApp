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
    
    
    //MARK: - Cell top labels
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        if indexPath.section % 3 == 0 {
            let showLoadMore = (indexPath.section == 0) && allLocalMessages.count > displayingMessagesCount
            let text = showLoadMore ? "Pull to load more messages" : MessageKitDateFormatter.shared.string(from: message.sentDate)
            let font = showLoadMore ? UIFont.systemFont(ofSize: 13) : UIFont.boldSystemFont(ofSize: 10)
            let color = showLoadMore ? UIColor.systemOrange : UIColor.systemGray2
            
            return NSAttributedString(string: text, attributes: [.font : font, .foregroundColor : color])
        }
        
        return nil
    }
    
    
    //MARK: - Cell bottom labels
    
    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        if isFromCurrentSender(message: message) {
            let message = mkMessages[indexPath.section]
            let status = indexPath.section == mkMessages.count - 1 ? message.status + " " + message.readDate.timeData() : ""
  
            return NSAttributedString(string: status, attributes: [.font: UIFont.boldSystemFont(ofSize: 10), .foregroundColor: UIColor.systemGray2])
        }
        
        return nil
    }
    
    //MARK: - Message bottom labels
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
            let font = UIFont.boldSystemFont(ofSize: 10)
            let color = UIColor.systemGray2
            return NSAttributedString(string: message.sentDate.timeData(), attributes: [.font: font, .foregroundColor: color])
 
    }
    
}

    //MARK: - ChannelChatViewController extension data source

extension ChannelChatViewController: MessagesDataSource {
    
    func currentSender() -> SenderType {
        return currentUser
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        
        return mkMessages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        mkMessages.count
    }
    
    
    //MARK: - Cell top Labels
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        if indexPath.section % 3 == 0 {
            
            let showLoadMore = (indexPath.section == 0) && (allLocalMessages.count > displayingMessagesCount)
            let text = showLoadMore ? "Pull to load more" : MessageKitDateFormatter.shared.string(from: message.sentDate)
            let font = showLoadMore ? UIFont.systemFont(ofSize: 13) : UIFont.boldSystemFont(ofSize: 10)
            let color = showLoadMore ? UIColor.systemBlue : UIColor.darkGray
            
            return NSAttributedString(string: text, attributes: [.font : font, .foregroundColor : color])
        }
        
        return nil
    }

    
    //Message bottom Label
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        return NSAttributedString(string: message.sentDate.timeData(), attributes: [.font : UIFont.boldSystemFont(ofSize: 10), .foregroundColor: UIColor.darkGray])
    }
}
