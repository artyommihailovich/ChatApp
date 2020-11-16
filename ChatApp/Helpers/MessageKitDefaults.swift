//
//  MessageKitDefaults.swift
//  ChatApp
//
//  Created by Artyom Mihailovich on 11/16/20.
//

import UIKit
import MessageKit

struct MKSender: SenderType, Equatable {
    var senderId: String
    var displayName: String
}

enum MessageDefaults {
    //Bubble
    static let bubbleColorOutGoing = UIColor(named: "ChatOutgoingBubble") ?? UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
    
    static let bubbleColorInComing = UIColor(named: "ChatIncomingBubble") ?? UIColor(red: 230/255, green: 229/255, blue: 234/255, alpha: 1.0)
}
