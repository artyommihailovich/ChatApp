//
//  FirebaseChannelListener.swift
//  ChatApp
//
//  Created by Artyom Mihailovich on 12/19/20.
//

import Foundation
import Firebase

class FirebaseChannelListener {
    
    //MARK: - Singleton
    
    static let shared = FirebaseChannelListener()
    
    private init() { }
    
    
    //MARK: - Variables
    
    var channelListener: ListenerRegistration!
    
    
    //MARK: - Fetching
    
    func downloadUserChannelsFromFirebase(completion: @escaping(_ allChannels: [Channel]) -> Void) {
        channelListener = firebaseReference(.Channel).whereField(kADMINID, isEqualTo: User.currentId).addSnapshotListener({ (querySnapshot, error) in
            
            guard let documents = querySnapshot?.documents else {
                print("No documents of user channel")
                return
            }
            
            var allChannels = documents.compactMap { (queryDocumentSnapshot) -> Channel? in
                
                return try? queryDocumentSnapshot.data(as: Channel.self)
            }
            
            allChannels.sort(by: { $0.memberIds.count > $1.memberIds.count })
            completion(allChannels)
        })
    }
    
    func downloadSubscribedChannels(completion: @escaping(_ allChannels: [Channel]) -> Void) {
        channelListener = firebaseReference(.Channel).whereField(kMEMBERIDS, arrayContains: User.currentId).addSnapshotListener({ (querySnapshot, error) in
                
                guard let documents = querySnapshot?.documents else {
                    print("No documents of subscribed channel")
                    return
                }
                
                var allChannels = documents.compactMap { (queryDocumentSnapshot) -> Channel? in
                    
                    return try? queryDocumentSnapshot.data(as: Channel.self)
                }
                
                allChannels.sort(by: { $0.memberIds.count > $1.memberIds.count })
                completion(allChannels)
        })
    }
    
    func downloadAllChannels(completion: @escaping(_ allChannels: [Channel]) -> Void) {
        
        firebaseReference(.Channel).getDocuments { (querySnapshot, error) in
                
                guard let documents = querySnapshot?.documents else {
                    print("No documents of user all channel")
                    return
                }
                
                var allChannels = documents.compactMap { (queryDocumentSnapshot) -> Channel? in
                    
                    return try? queryDocumentSnapshot.data(as: Channel.self)
                }
            
                allChannels = self.removeSubscribedChannels(allChannels)
                
                allChannels.sort(by: { $0.memberIds.count > $1.memberIds.count })
                completion(allChannels)
        }
    }
    
    
    //MARK: - Add, update, delete methods
    
    func saveChannel(_ channel: Channel) {
        
        do {
            try firebaseReference(.Channel).document(channel.id).setData(from: channel)
        } catch  {
            print("Error saving channel ", error.localizedDescription)
        }
    }
    
    func deleteChannel(_ channel: Channel) {
        firebaseReference(.Channel).document(channel.id).delete()
    }
    
    
    //MARK: - Helpers
    
    func removeSubscribedChannels(_ allChannels: [Channel]) -> [Channel] {
        var newChannels: [Channel] = []
        
        for channel in allChannels {
            if channel.memberIds.contains(User.currentId) {
                newChannels.append(channel)
            }
        }
        
        return newChannels
    }
    
    func removeChannelListener() {
        self.channelListener.remove()
    }
}
