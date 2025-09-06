//
//  OnboardingView.swift
//  Clio
//
//  Created by Vivien on 9/4/25.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var session: SessionManager

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Text("Welcome to Clio")
                .font(.largeTitle).bold()
            Text("Gentle, mood-based book discovery. Save favorites, build lists, and share.")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            Spacer()
            VStack(spacing: 12) {
                Button {
                    session.startAsGuest()
                } label: {
                    Text("Continue as Guest")
                        .frame(maxWidth: .infinity)
                        .padding().background(Color.accentColor.opacity(0.12))
                        .foregroundColor(.accentColor).cornerRadius(12)
                }
                NavigationLink {
                    AuthView()
                } label: {
                    Text("Sign In / Create Account")
                        .frame(maxWidth: .infinity)
                        .padding().background(Color.accentColor)
                        .foregroundColor(.white).cornerRadius(12)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 28)
            
#if DEBUG
Text("Mode: Guest=\(session.isGuest ? "Yes" : "No")  UID=\(session.uid ?? "nil")")
    .font(.footnote)
    .foregroundColor(.secondary)
    .padding(.top, 8)
#endif
        }
        .padding(.top, 32)
        .navigationTitle("")
        .navigationBarHidden(true)
    }
}

#Preview {
    OnboardingView()
}
