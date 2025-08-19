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
    @AppStorage("uid") var uid: String?
    @StateObject private var savedBooks = SavedBooksManager()
    @StateObject private var readingListManager = ReadingListManager()
    @StateObject private var linkRouter = LinkRouter()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            if let _ = uid {
                ContentView()
                    .onAppear {
                        readingListManager.configure(savedBooksManager: savedBooks)
                    }
                    .onOpenURL { url in
                        print("📬 Received URL: \(url)")
                        linkRouter.handleDeepLink(url)
                    }
                    .environmentObject(savedBooks)
                    .environmentObject(readingListManager)
                    .environmentObject(linkRouter)
            } else {
                AuthView()
                    .onOpenURL { url in
                        print("📬 Received URL (AuthView): \(url)")
                        linkRouter.handleDeepLink(url)
                    }
            }
        }
    }
}

