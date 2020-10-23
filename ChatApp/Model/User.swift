//
//  User.swift
//  ChatApp
//
//  Created by Artyom Mihailovich on 9/27/20.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift


struct User: Codable, Equatable {
    var id = ""
    var username: String
    var email: String
    var pushId = ""
    var avatarLink = ""
    var status: String
    
    static var currentId: String {
        return Auth.auth().currentUser!.uid
    }
    
    // Current user
    static var currentUser: User? {
        if Auth.auth().currentUser != nil {
            if let dictionary = UserDefaults.standard.data(forKey: kCURRENTUSER) {
                
                let decoder = JSONDecoder()
                
                do {
                    let userObject = try decoder.decode(User.self, from: dictionary)
                    return userObject
                } catch  {
                    print("DEBUG: - Error decoding from user defaults!", error.localizedDescription)
                }
            }
        }
        return nil
    }
    
    // Function for Equatable our users
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
}

    func saveUserLocally(_ user: User) {
        
        let encoder = JSONEncoder()
        
        do {
            let data = try encoder.encode(user)
            UserDefaults.standard.set(data, forKey: kCURRENTUSER)
        } catch {
            print("DEBUG! - Error to saving user locally! ", error.localizedDescription)
        }
}


    //MARK: - Create some dummy users

func createDummyUsers() {
    
    print("Creating dummy users")
    
    let names = ["Ignat Voyna", "Egor Rezanov", "Ivan Novii", "Anton Bychok", "Sheck Sheck"]
    
    var imageIndex = 1
    var userIndex = 1
    
    for i in 0..<5 {
        let id = UUID().uuidString
        
        let fileDirrectory = "Avatars/" + "\(id)" + ".jpg"
        
        FileStorage.uploadImage(UIImage(named: "user\(imageIndex)")!, directory: fileDirrectory) { (avatarLink) in
            let user = User(id: id, username: names[i], email: "user\(userIndex)@mail.com", pushId: "", avatarLink: avatarLink ?? "", status: "No status")
            
            userIndex += 1
            FirebaseUserListener.shared.saveUserToFirestore(user)
        }
        imageIndex += 1
        
        if imageIndex == 5 {
            imageIndex = 1
        }
    }
}
