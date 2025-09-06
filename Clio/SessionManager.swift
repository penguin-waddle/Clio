//
//  SessionManager.swift
//  Clio
//
//  Created by Vivien on 9/4/25.
//

import Foundation
import SwiftUI
import FirebaseAuth

final class SessionManager: ObservableObject {
    @AppStorage("uid") var uid: String?
    @AppStorage("isGuest") var isGuest: Bool = false
    @Published var ready: Bool = false

    func startAsGuest() {
        isGuest = true
        uid = nil
    }

    func onSignedIn(uid: String) {
        self.uid = uid
        isGuest = false
    }

    func signOut() {
        try? Auth.auth().signOut()
        uid = nil
        isGuest = false
    }

    /// Call once at app start (after FirebaseApp.configure()).
    func bootstrap() {
        if Auth.auth().currentUser != nil {
            isGuest = false
        } else {
            uid = nil          // ← clear stale uid if not signed in
        }
        ready = true
    }
}
