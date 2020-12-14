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
    
    //MARK: - Singleton
    
    static let shared = FirebaseMessageListener()
    
    private init() {}
    
    
    //MARK: - Variables
    
    var newChatListener: ListenerRegistration!
    var updateChatListener: ListenerRegistration!
    
    
    
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
                            
                            if message.senderId != User.currentId {
 
                                RealmManager.shared.saveToRealm(message)
                            }
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
    
    
    //MARK: - Read status change listener
    
    func listenForReadStatusChange(_ documentId: String, collectionId: String, completion: @escaping(_ updatedMessage: LocalMessage) -> Void) {
        updateChatListener = firebaseReference(.Messages).document(documentId).collection(collectionId).addSnapshotListener({ querySnapshot, error in
            
            guard let snapshot = querySnapshot else { return }
            
            for change in snapshot.documentChanges {
                
                if change.type == .modified {
                     
                    let result = Result {
                        try? change.document.data(as: LocalMessage.self)
                    }
                    
                    switch result {
                    case .success(let messageObject):
                        if let message = messageObject {
                            completion(message)
                        } else {
                            print("Document does not exist in chat!")
                        }
                    case .failure(let error):
                        print("Error decoding local message: " , error.localizedDescription)
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
    
    //Add
    func addMessage(_ message: LocalMessage, memberId: String) {
        do {
            let _ = try firebaseReference(.Messages).document(memberId).collection(message.chatRoomId).document(message.id).setData(from: message)
        } catch  {
            print("Error saving message! ", error.localizedDescription)
        }
    }
    
    
    //Update message status
    func updateMessageInFirebase(_ message: LocalMessage, memberIds: [String] ) {
        let values = [kSTATUS : kREAD, kREADDATE : Date()] as [String: Any]
        
        for userId in memberIds {
            firebaseReference(.Messages).document(userId).collection(message.chatRoomId).document(message.id).updateData(values)
        }
    }
    
    
    func removeListeners() {
        self.newChatListener.remove()
       // self.updateChatListener.remove()
    }
    
}
