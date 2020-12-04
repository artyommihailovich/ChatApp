//
//  FirebaseMessageListener.swift
//  ChatApp
//
//  Created by Artyom Mihailovich on 12/4/20.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class FirebaseMessageListener  {
    
    static let shared = FirebaseMessageListener()
    
    private init() {}
    
    //MARK: - Add, Update, Delete
    
    func addMessage(_ message: LocalMessage, memberId: String) {
        do {
            let _ = try firebaseReference(.Messages).document(memberId).collection(message.chatRoomId).document(message.id).setData(from: message)
        } catch  {
            print("Error saving message! ", error.localizedDescription)
        }
    }
}
