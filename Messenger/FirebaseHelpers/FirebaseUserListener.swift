//
//  FirebaseUserListener.swift
//  Messenger
//
//  Created by Miguel Angel Gutierrez Maya on 23/11/23.
//

import Foundation
import Factory
import FirebaseAuth

class FirebaseUserListener {
    /// Injected property for Auth
    @Injected(\.auth) private var auth: Auth
    
    static let shared = FirebaseUserListener()
    
    private init() {}
    
    // MARK: - Login
    func loginUserWithEmail(email: String, password: String, completion: @escaping(_ error: Error?, _ isEmailVerified: Bool) -> Void) {
        auth.signIn(
            withEmail: email,
            password: password
        ) { (authDataResult, error) in
            if let error = error {
                self._errorCompletion(
                    error: error,
                    completion: completion
                )
                return
            }
            
            if let user = authDataResult?.user {
                if user.isEmailVerified {
                    FirebaseUserListener.shared.downloadUserFromFirebase(
                        userId: user.uid,
                        email: email
                    )
                    
                    completion(error, true)
                } else {
                    self._errorCompletion(
                        error: error,
                        completion: completion
                    )
                }
            } else {
                self._errorCompletion(
                    error: error,
                    completion: completion
                )
            }
        }
    }
    
    private func _errorCompletion(
        error: Error?,
        completion: @escaping(_ error: Error?, _ isEmailVerified: Bool) -> Void) {
            print("email is not verified")
            completion(error, false)
        }
    
    
    // MARK: - Register
    func registerUserWith(
        email: String,
        password: String,
        completion: @escaping (_ error: Error?) -> Void
    ) {
        auth.createUser(withEmail: email, password: password) { (authDataResult, error) in
            if let error = error {
                completion(error)
                return
            }
            
            if let authData = authDataResult {
                
                // Send verification email
                authData.user.sendEmailVerification { error in
                    if let error = error {
                        print("auth email verification error: ", error.localizedDescription)
                        completion(error)
                    }
                }
                
                // Save user in database
                let user = User(
                    id: authData.user.uid,
                    username: email,
                    email: email,
                    pushId: "",
                    avatarLink: "",
                    status: "Hey there! I am using Messenger."
                )
                
                saveUserLocally(user)
                self.saveUserToFirestore(user)
            } else {
                print("authDataResult is nil")
            }
            
            completion(error)
        }
    }
    
    // MARK: - Resend link methods
    func resendVerificationEmail(email: String, completion: @escaping (_ error: Error?) -> Void) {
        auth.currentUser?.reload(completion: { (error) in
            
            if let error = error {
                return completion(error)
            }
            
            self.auth.currentUser?.sendEmailVerification(completion: { (error) in
                completion(error)
            })
        })
    }
    
    func resetPassword(email: String, completion: @escaping (_ error: Error?) -> Void) {
        auth.sendPasswordReset(withEmail: email) { (error) in
            completion(error)
        }
    }
    
    func logOutCurrentUser(completion: @escaping (_ error: Error?) -> Void) {
        do {
            try auth.signOut()
            
            userDefaults.removeObject(forKey: kCURRENTUSER)
            userDefaults.synchronize()
            completion(nil)
        } catch let error as NSError {
            completion(error)
        }
    }
    
    // MARK: - Save user
    func saveUserToFirestore(_ user: User) {
        do {
            try FirebaseReference.get(.User).document(user.id).setData(from: user)
        } catch {
            print(error.localizedDescription, "Adding user \(error)")
        }
    }
    
    // MARK: - Download user
    func downloadUserFromFirebase(userId: String, email: String? = nil) {
        FirebaseReference.get(.User).document(userId).getDocument { (querySnapshot, error) in
            guard let document = querySnapshot else {
                print("no document for user")
                return
            }
            
            let result = Result {
                try? document.data(as: User.self)
            }
            
            switch result {
            case .success(let userObject):
                if let user = userObject {
                    saveUserLocally(user)
                } else {
                    print("Document does not exist")
                }
            case .failure(let error):
                print("Error decoding user: \(error.localizedDescription)")
            }
        }
    }
    
    func downloadAllUsersFromFirebase(completion: @escaping (_ allUsers: [User]) -> Void) {
        var users: [User] = []
        
        FirebaseReference
            .get(.User)
            .limit(to: 500)
            .getDocuments { (querySnapshot, error) in
                guard let document = querySnapshot?.documents else {
                    print("No documents in all users")
                    return
                }
                
                let allUsers = document.compactMap { (queryDocumentSnapshot) -> User? in
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
    
    func downloadUsersFromFirebase(withIds: [String], completion: @escaping (_ allUsers: [User]) -> Void) {
        var count = 0
        var usersArray: [User] = []
        
        for userId in withIds {
            FirebaseReference
                .get(.User)
                .document(userId)
                .getDocument { (querySnapshot, error) in
                    guard let document = querySnapshot else {
                        print("No document for user")
                        return
                    }
                    
                    let user = try? document.data(as: User.self)
                    
                    usersArray.append(user!)
                    count += 1
                    
                    if count == withIds.count {
                        completion(usersArray)
                    }
                }
        }
    }
}
