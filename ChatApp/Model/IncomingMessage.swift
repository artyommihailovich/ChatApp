//
//  IncomingMessage.swift
//  ChatApp
//
//  Created by Artyom Mihailovich on 12/4/20.
//

import Foundation
import MessageKit
import CoreLocation

class IncomingMessage {
    
    var messageCollectionView: MessagesViewController
    
    init(_collectionView: MessagesViewController) {
        messageCollectionView = _collectionView
    }
    
    
    //MARK: - Create message
    
    func createMessage(localMessage: LocalMessage) -> MKMessage? {
        let mkMessage = MKMessage(message: localMessage)
        
        //Multimedia messages
        
        return mkMessage
    }
}
