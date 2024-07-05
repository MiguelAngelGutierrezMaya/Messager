//
//  User.swift
//  Messenger
//
//  Created by Miguel Angel Gutierrez Maya on 20/11/23.
//

import Foundation
import Factory
import FirebaseAuth

class UserUtilsFirebase {
    @Injected(\.auth) static var auth: Auth
}

class UserUtils {
    @Injected(\.userPreferences) static var userPreferences: UserDefaults
}

struct User: Codable, Equatable {
    var id = ""
    var username: String
    var email: String
    var pushId: String? = ""
    var avatarLink: String = ""
    var status: String
    
    static var currentId: String {
        return Auth.auth().currentUser!.uid
    }
    
    static var currentUser: User? {
        if UserUtilsFirebase.auth.currentUser != nil {
            if let dictionary = UserDefaults.standard.data(forKey: kCURRENTUSER) {
                let decoder = JSONDecoder()
                
                do {
                    let userObject = try decoder.decode(User.self, from: dictionary)
                    return userObject
                } catch {
                    print("Error decoding user from user defaults", error.localizedDescription)
                }
            }
        }
        
        return nil
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
}

func saveUserLocally(_ user: User) {
    let encoder = JSONEncoder()
    
    do {
        let data = try encoder.encode(user)
        UserUtils.userPreferences.set(data, forKey: kCURRENTUSER)
    } catch {
        print("Error saving user locally", error.localizedDescription)
    }
}

func createDummyUsers() {
    print("Creating users")
    
    let names = ["Miguel Angel 2", "Jorge", "Luis", "Carlos", "Jose", "Juan", "Pedro", "Pablo", "David", "Daniel"]
    
    var imageIndex = 1
    var userIndex = 1
    
    for i in 0..<5 {
        let id = UUID().uuidString
        let fileDirectory = "Avatars/" + "_\(id)" + ".jpg"
        
        FileStorage.uploadImage(UIImage(named: "user\(imageIndex)")!, directory: fileDirectory) { (avatarLink) in
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
