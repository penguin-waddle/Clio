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
    func logOut() {
        do {
            try Auth.auth().signOut()
            UserDefaults.standard.removeObject(forKey: "uid")
        } catch {
            print("❌ Logout failed: \(error.localizedDescription)")
        }
    }

    // Get current UID
    var currentUID: String? {
        return Auth.auth().currentUser?.uid
    }

    // Check if logged in
    var isSignedIn: Bool {
        return Auth.auth().currentUser != nil
    }
    
}
