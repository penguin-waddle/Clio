//
//  PreviewWrapper.swift
//  Clio
//
//  Created by Vivien on 7/10/25.
//

import SwiftUI

/// A wrapper that injects common environment objects for SwiftUI previews.
struct PreviewWrapper<Content: View>: View {
    @StateObject private var session: SessionManager
    @StateObject private var linkRouter: LinkRouter
    @StateObject private var savedBooks: SavedBooksManager
    @StateObject private var readingListManager: ReadingListManager

    let content: () -> Content

    init(
        session: SessionManager = {
            let s = SessionManager()
            s.isGuest = true        // previews act like Guest
            s.uid = nil
            s.ready = true
            return s
        }(),
        linkRouter: LinkRouter = LinkRouter(),
        savedBooks: SavedBooksManager = SavedBooksManager(),
        readingListManager: ReadingListManager = ReadingListManager(),
        @ViewBuilder content: @escaping () -> Content
    ) {
        _session = StateObject(wrappedValue: session)
        _linkRouter = StateObject(wrappedValue: linkRouter)
        _savedBooks = StateObject(wrappedValue: savedBooks)
        _readingListManager = StateObject(wrappedValue: readingListManager)
        self.content = content
    }

    var body: some View {
        content()
            .environmentObject(session)
            .environmentObject(linkRouter)
            .environmentObject(savedBooks)
            .environmentObject(readingListManager)
            .onAppear {
                // Wire managers together for previews
                readingListManager.configure(savedBooksManager: savedBooks)
                savedBooks.refresh(for: session.uid, isGuest: session.isGuest)
            }
    }
}

