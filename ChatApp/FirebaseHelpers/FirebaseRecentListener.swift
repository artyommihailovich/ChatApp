//
//  FirebaseRecentListener.swift
//  ChatApp
//
//  Created by Artyom Mihailovich on 11/2/20.
//

import Foundation
import Firebase

class FirebaseRecentListener {
    
    // Singleton
    static let shared = FirebaseRecentListener()
    
    private init() {}
    
    func downlopadRecentChatsFromFirestore(completion: @escaping(_ allRecents: [RecentChat]) -> Void) {
        firebaseReference(.Recent).whereField(kSENDERID, isEqualTo: User.currentId).addSnapshotListener { (querySnapshot, erroe) in
            var recentChats: [RecentChat] = []
            
            guard let documents = querySnapshot?.documents else {
                print("No documents for recent chats")
                
                return
            }
            
            let allRecent = documents.compactMap { (queryDocumentSnapshot) -> RecentChat? in
             
                return try? queryDocumentSnapshot.data(as: RecentChat.self)
            }
            
            for recent in allRecent {
                if recent.lastMessage != "" {
                    recentChats.append(recent)
                }
            }
            
            recentChats.sort(by: {$0.date! > $1.date!})
            completion(recentChats)
        }
    }
    
    func addRecent(_ recent: RecentChat) {
        do {
           try firebaseReference(.Recent).document(recent.id).setData(from: recent)
        } catch {
            print("Error saving recent chat", error.localizedDescription)
        }
    }
}
