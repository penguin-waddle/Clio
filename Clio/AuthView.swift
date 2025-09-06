//
//  AuthView.swift
//  Clio
//
//  Created by Vivien on 7/14/25.
//

import SwiftUI

struct AuthView: View {
    @EnvironmentObject var session: SessionManager
    @State private var email = ""
    @State private var password = ""
    @State private var isNewUser = true
    @State private var errorMessage: String?
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 24) {
            Text(isNewUser ? "Create Account" : "Welcome Back")
                .font(.largeTitle).bold()

            TextField("Email", text: $email)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .autocorrectionDisabled(true)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            SecureField("Password", text: $password)
                .textContentType(.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            if let error = errorMessage {
                Text(error).foregroundColor(.red).font(.caption)
            }

            Button {
                Task { await handleAuth() }
            } label: {
                if isLoading {
                    ProgressView().frame(maxWidth: .infinity)
                } else {
                    Text(isNewUser ? "Sign Up" : "Log In")
                        .frame(maxWidth: .infinity)
                }
            }
            .padding()
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(8)
            .disabled(isLoading)

            Button {
                isNewUser.toggle()
                errorMessage = nil
            } label: {
                Text(isNewUser ? "Already have an account? Log in" : "New user? Sign up")
                    .font(.footnote)
                    .foregroundColor(.blue)
            }
        }
        .padding()
    }

    private func handleAuth() async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Email and password required"
            return
        }
        isLoading = true
        defer { isLoading = false }

        do {
            let newUID: String
            if isNewUser {
                newUID = try await AuthManager.shared.signUp(email: email, password: password)
            } else {
                newUID = try await AuthManager.shared.logIn(email: email, password: password)
            }
            // Single source of truth:
            session.onSignedIn(uid: newUID)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview { AuthView().environmentObject(SessionManager()) }
