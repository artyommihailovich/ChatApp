//
//  FirebaseTypingListener.swift
//  ChatApp
//
//  Created by Artyom Mihailovich on 12/11/20.
//

import Foundation
import Firebase

class FirebaseTypingListener {
    
    //MARK: - Singleton
    
    static let shared = FirebaseTypingListener()
    
    private init() {}
    
    //MARK: - Variables
    
    var typingListener: ListenerRegistration!
    
    
    //MARK: - Create tyoing observer
    
    func createTypingObserver(chatRoomId: String, completion: @escaping(_ isTyping: Bool) -> Void) {
        
        typingListener = firebaseReference(.Typing).document(chatRoomId).addSnapshotListener({ (snapShot, error) in
            guard let snapShot = snapShot else { return }
            
            if snapShot.exists {
                
                for data in snapShot.data()! {
                    if data.key != User.currentId {
                        completion(data.value as! Bool)
                    }
                }
                
            } else {
                firebaseReference(.Typing).document(chatRoomId).setData([User.currentId : false])
            }
        })
    }
    
    class func saveTypingCounter(typing: Bool, chatRoomId: String) {
        firebaseReference(.Typing).document(chatRoomId).updateData([User.currentId : typing])
    }
    
    func removeTypingListener() {
        self.typingListener.remove()
    }
}
