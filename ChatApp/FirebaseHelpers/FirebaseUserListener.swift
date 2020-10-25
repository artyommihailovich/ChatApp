//
//  FirebaseUserListener.swift
//  ChatApp
//
//  Created by Artyom Mihailovich on 9/27/20.
//

import Foundation
import Firebase

class FirebaseUserListener {
    static let shared = FirebaseUserListener()
    
    // Create singleton
    private init () {}
    
    
    //MARK: - Login
    
    func loginUserWithEmail(email: String, password: String, completion: @escaping (_ error: Error?, _ isEmailVerified: Bool) -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: password) { (authDataResult, error) in
            if error == nil && authDataResult!.user.isEmailVerified {
                
                FirebaseUserListener.shared.downloadUserFromFirebase(userId: authDataResult!.user.uid, email: email)
                
                completion(error, true)
            } else {
                print("email is not verified")
                completion(error, false)
            }
        }
    }
    
    //MARK: - Register
    
    func registerUserWith(email: String, password: String, completion: @escaping (_ error: Error?) -> Void) {
        
        Auth.auth().createUser(withEmail: email, password: password) { (authDataResult, error) in
            completion(error)
            
            if error == nil {
                // Send email verification
                authDataResult!.user.sendEmailVerification { (error) in
                    print("ERROR: - Authentication email sent is error!", error?.localizedDescription)
                }
                
                // Create user object an save it
                if authDataResult?.user != nil {
                    // Custom user object
                    let user = User(id: authDataResult!.user.uid, username: email, email: email, pushId: "", avatarLink: "", status: "Hey there! I'm using ChatApp!")
                    
                    saveUserLocally(user)
                    self.saveUserToFirestore(user)
                }
            }
        }
    }
    
    func logOutCurrentUser(completion: @escaping (_ error: Error?) -> Void) {
        
        do {
            try Auth.auth().signOut()
            
            userDefaults.removeObject(forKey: kCURRENTUSER)
            userDefaults.synchronize()
            
            completion(nil)
        } catch let error as NSError {
            completion(error)
        }

    }
    
    //MARK: - Save Users
    
    func saveUserToFirestore(_ user: User) {
        
        do {
            try firebaseReference(.User).document(user.id).setData(from: user)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    //MARK: - Resend link methods
    
    func resendVerificationEmail(email: String, completion: @escaping (_ error: Error?) -> Void) {
        
        // - Reload login
        Auth.auth().currentUser?.reload(completion: { (error) in
            
            Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
                completion(error)
            })
        })
    }
    
    func resetPasswordFor(email: String, completion: @escaping (_ error: Error?) -> Void) {
        
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            completion(error)
        }
    }
    
    
    //MARK: - Download
    
    func downloadUserFromFirebase(userId: String, email: String? = nil) {
        // Go to up folder
        firebaseReference(.User).document(userId).getDocument { (querySnapshot, error) in
            
            guard let document = querySnapshot else {
                print("ERROR: - No document for user!")
                return
            }
            
            let result = Result {
                try? document.data(as: User.self)
            }
            
            // Check what result was
            switch result {
            case .success(let userObject):
                if let user = userObject {
                    saveUserLocally(user)
                } else {
                    print("ERROR: - Document does not exist!")
                }
            case .failure(let error):
                print("ERROR: - Error user!", error)
            }
        }
    }
    
    func downloadAllUsersFromFirebase(completion: @escaping(_ allUsers: [User]) -> Void) {
        var users: [User] = []
        
        firebaseReference(.User).limit(to: 500).getDocuments { (querySnapshot, error) in
            guard let document = querySnapshot?.documents else {
                print("ERROR: - No documents in all users!")
                
                return
            }
            let allUsers = document.compactMap {(queryDocumentSnapshot) -> User? in
                
            return try? queryDocumentSnapshot.data(as: User.self)
            }
            
            for user in allUsers {
                
                if User.currentId != user.id {
                    users.append(user)
                }
            }
            
            completion(users)
        }
    }
    
    func downloadUsersFromFirebase(withIds: [String], completion: @escaping(_ allUsers: [User]) -> Void) {
        var count = 0
        var userArray: [User] = []
        
        for userId in withIds {
            firebaseReference(.User).document(userId).getDocument { (querySnapshot, error) in
                
                guard let document = querySnapshot else {
                    print("ERROR: - No document for user!")
                    
                    return
                }
                
                let user = try? document.data(as: User.self)
                
                userArray.append(user!)
                count += 1
                
                if count == withIds.count {
                    completion(userArray)
                }
            }
        }
    }
}
