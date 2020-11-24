//
//  InputBarAccessoryViewDelgate.swift
//  ChatApp
//
//  Created by Artyom Mihailovich on 11/15/20.
//

import Foundation
import InputBarAccessoryView

extension ChatViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        if text != "" {
            print("Typing...")
        }
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        for component in inputBar.inputTextView.components {
            if let text = component as? String {
                print("Send message with text ", text)
            }
        }
        messageInputBar.inputTextView.text = ""
        messageInputBar.invalidatePlugins()
    }
}
