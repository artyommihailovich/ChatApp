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
    
    
    
    //MARK: - Add, update, delete methods
    
    func addChannel(_ channel: Channel) {
        
        do {
            try firebaseReference(.Channel).document(channel.id).setData(from: channel)
        } catch  {
            print("Error saving channel ", error.localizedDescription)
        }
    }
}
