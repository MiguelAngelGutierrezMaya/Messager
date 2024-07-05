//
//  FCollectionReference.swift
//  Messenger
//
//  Created by Miguel Angel Gutierrez Maya on 23/11/23.
//

import Foundation
import Factory
import FirebaseFirestore

enum FCollectionReference: String {
    case User
    case Recent
    case Message
    case Typing
    case Channel
}

// Make static so it can be used without injection
class FirebaseReference {
    @Injected(\.firestore) static var firestore
    
    static func get(
        _ collectionReference: FCollectionReference
    ) -> CollectionReference {
        return firestore.collection(collectionReference.rawValue)
    }
}
