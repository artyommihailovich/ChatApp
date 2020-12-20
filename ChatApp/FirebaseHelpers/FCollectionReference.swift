//
//  FCollectionReference.swift
//  ChatApp
//
//  Created by Artyom Mihailovich on 9/27/20.
//
//  This helper for registration our user!

import Foundation
import FirebaseFirestore

enum FCollectionReference: String {
    case User
    case Recent
    case Messages
    case Typing
    case Channel
}

func firebaseReference(_ collectionReference: FCollectionReference) -> CollectionReference {
    return Firestore.firestore().collection(collectionReference.rawValue)
}
