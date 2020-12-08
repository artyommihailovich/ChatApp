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
    
    //MARK: - Variables
    
    var newChatListener: ListenerRegistration!
    var updateChatListener: ListenerRegistration!
    
    
    private init() {}
    
    
    //MARK: - Listen for new chats
    
    func listenForNewChats(_ documentId: String, collectionId: String, lastMessageDate: Date) {
        newChatListener = firebaseReference(.Messages).document(documentId).collection(collectionId).whereField(kDATE, isGreaterThan: lastMessageDate).addSnapshotListener({ (querySnapshot, error) in
            
            guard let snapShot = querySnapshot else { return }
            
            for change in snapShot.documentChanges {
                if change.type == .added {
                    
                    let result = Result {
                        
                        try? change.document.data(as: LocalMessage.self)
                    }
                    
                    switch result {
                    case .success(let messageObject):
                        if let message = messageObject {
                            RealmManager.shared.saveToRealm(message)
                        } else {
                            print("Document does not exist!")
                        }
                    case .failure(let error):
                        print("Error docoding local chat: \(error.localizedDescription)")
                    }
                }
            }
        })
    }
   
    
    //MARK: - Check for old chats
    
    func checkForOldChats(_ documentId: String, collectionId: String) {
        
        // Firebase part
        
        firebaseReference(.Messages).document(documentId).collection(collectionId).getDocuments { (querySnapshot, error) in
            
            guard let documents = querySnapshot?.documents else {
                print("No documents for old chats")
                return
            }
            
            var oldMessages = documents.compactMap { (queryDocumentSnapshot) -> LocalMessage? in
                return try? queryDocumentSnapshot.data(as: LocalMessage.self)
            }
            
            oldMessages.sort(by: {$0.date < $1.date})
            
            //Realm part
            
            for message in oldMessages {
                RealmManager.shared.saveToRealm(message)
            }
        }
    }
    
    
    //MARK: - Add, Update, Delete
    
    func addMessage(_ message: LocalMessage, memberId: String) {
        do {
            let _ = try firebaseReference(.Messages).document(memberId).collection(message.chatRoomId).document(message.id).setData(from: message)
        } catch  {
            print("Error saving message! ", error.localizedDescription)
        }
    }
}
