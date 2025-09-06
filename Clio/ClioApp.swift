//
//  ClioApp.swift
//  Clio
//
//  Created by Vivien on 7/4/25.
//

import FirebaseCore
import SwiftUI

@main
struct ClioApp: App {
    @StateObject private var session = SessionManager()
    @StateObject private var savedBooks = SavedBooksManager()
    @StateObject private var readingListManager = ReadingListManager()
    @StateObject private var linkRouter = LinkRouter()

    init() { FirebaseApp.configure() }

    var body: some Scene {
        WindowGroup {
            contentRoot
                .environmentObject(session)
                .environmentObject(savedBooks)
                .environmentObject(readingListManager)
                .environmentObject(linkRouter)
        }
    }

    @ViewBuilder
    private var contentRoot: some View {
        if session.ready == false {
            ProgressView("Starting…")
                .task { session.bootstrap() }
        } else if session.isGuest == false, session.uid == nil {
            // Onboarding (neither guest nor signed in)
            NavigationStack {
                OnboardingView()
            }
            .onOpenURL { url in
                print("📬 Received URL (Onboarding): \(url)")
                linkRouter.handleDeepLink(url)
            }
        } else {
            // Guest or signed-in share the same root UI
            ContentView()
                .onAppear {
                    readingListManager.configure(savedBooksManager: savedBooks)
                }
                .onOpenURL { url in
                    print("📬 Received URL: \(url)")
                    linkRouter.handleDeepLink(url)
                }
                // Refresh saved books when session changes
                .task(id: session.ready) {
                    if session.ready {
                        savedBooks.refresh(for: session.uid, isGuest: session.isGuest)
                    }
                }
                .task(id: session.isGuest) {
                    savedBooks.refresh(for: session.uid, isGuest: session.isGuest)
                }
                .task(id: session.uid) {
                    savedBooks.refresh(for: session.uid, isGuest: session.isGuest)
                }
        }
    }
}
