//
//  PreviewWrapper.swift
//  Clio
//
//  Created by Vivien on 7/10/25.
//

import SwiftUI

/// A wrapper that injects common environment objects for SwiftUI previews.
struct PreviewWrapper<Content: View>: View {
    @StateObject private var savedBooks: SavedBooksManager
    @StateObject private var readingListManager: ReadingListManager
    let content: () -> Content

    init(
        savedBooks: SavedBooksManager = SavedBooksManager(),
        readingListManager: ReadingListManager = ReadingListManager(),
        @ViewBuilder content: @escaping () -> Content
    ) {
        _savedBooks = StateObject(wrappedValue: savedBooks)
        _readingListManager = StateObject(wrappedValue: readingListManager)
        self.content = content

        readingListManager.configure(savedBooksManager: savedBooks)
    }

    var body: some View {
        content()
            .environmentObject(savedBooks)
            .environmentObject(readingListManager)
    }
}

