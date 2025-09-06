//
//  AuthManager.swift
//  Clio
//
//  Created by Vivien on 7/14/25.
//

import Foundation
import FirebaseAuth

final class AuthManager {
    static let shared = AuthManager()
    private init() {}

    // Sign Up
    func signUp(email: String, password: String) async throws -> String {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        return result.user.uid
    }

    // Log In
    func logIn(email: String, password: String) async throws -> String {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        return result.user.uid
    }

    // Log Out
    func logOut() throws {
        try Auth.auth().signOut()
        // No UserDefaults writes here — SessionManager owns that.
    }

    var currentUID: String? { Auth.auth().currentUser?.uid }
    var isSignedIn: Bool { Auth.auth().currentUser != nil }
}
