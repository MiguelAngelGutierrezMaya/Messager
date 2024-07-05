//
//  User+Injection.swift
//  Messenger
//
//  Created by Miguel Angel Gutierrez Maya on 5/01/24.
//

import Foundation
import Factory

extension Container {
    public var userPreferences: Factory<UserDefaults> {
        return Factory(self) {
            return UserDefaults.standard
        }.singleton
    }
}
