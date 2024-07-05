//
//  Firebase+Injection.swift
//  Messenger
//
//  Created by Miguel Angel Gutierrez Maya on 23/11/23.
//

import Foundation
import Factory
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage

extension Container {
    public var auth: Factory<Auth> {
        return Factory(self) {
            return Auth.auth()
        }.singleton
    }
    
    public var firestore: Factory<Firestore> {
        return Factory(self) {
            return Firestore.firestore()
        }.singleton
    }
    
    public var storage: Factory<Storage> {
        return Factory(self) {
            return Storage.storage()
        }.singleton
    }
}
