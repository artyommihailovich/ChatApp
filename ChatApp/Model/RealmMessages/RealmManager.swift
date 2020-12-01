//
//  RealmManager.swift
//  ChatApp
//
//  Created by Artyom Mihailovich on 11/30/20.
//

import Foundation
import RealmSwift

class RealmManager {
    static let shared = RealmManager()
    let realm = try! Realm()
    
    private init () {
        
    }
    
    func saveToRealm<T: Object>(_ object: T) {
        
        do {
            try realm.write {
                realm.add(object, update: .all)
                // realm.delete(object)
            }
        } catch  {
            print("Error saving realm object!", error.localizedDescription)
        }
    }
}
