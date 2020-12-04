//
//  FCollectionReference.swift
//  ChatApp
//
//  Created by Artyom Mihailovich on 9/27/20.
//
//  This helper for registration our user!

import Foundation
import FirebaseFirestore

enum fCollectionReference: String {
    case User
    case Recent
    case Messages
}

func firebaseReference(_ collectionReference: fCollectionReference) -> CollectionReference {
    return Firestore.firestore().collection(collectionReference.rawValue)
}
