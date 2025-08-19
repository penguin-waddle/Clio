//
//  AuthView.swift
//  Clio
//
//  Created by Vivien on 7/14/25.
//

import SwiftUI

struct AuthView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isNewUser = true
    @State private var errorMessage: String?
    @AppStorage("uid") private var uid: String?

    var body: some View {
        VStack(spacing: 24) {
            Text(isNewUser ? "Create Account" : "Welcome Back")
                .font(.largeTitle)
                .bold()

            TextField("Email", text: $email)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            Button(action: {
                Task {
                    await handleAuth()
                }
            }) {
                Text(isNewUser ? "Sign Up" : "Log In")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }

            Button(action: {
                isNewUser.toggle()
                errorMessage = nil
            }) {
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

        do {
            if isNewUser {
                uid = try await AuthManager.shared.signUp(email: email, password: password)
            } else {
                uid = try await AuthManager.shared.logIn(email: email, password: password)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    AuthView()
}
