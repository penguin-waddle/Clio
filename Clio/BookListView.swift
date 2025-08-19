//
//  BookListView.swift
//  Clio
//
//  Created by Vivien on 7/4/25.
//

import SwiftUI

struct BookListView: View {
    let listID: String?
    let moodTag: MoodTag?

    @EnvironmentObject var readingListManager: ReadingListManager
    @State private var list: ReadingList?
    @State private var books: [Book] = []

    var body: some View {
        Group {
            if let list = list {
                listSection(for: list, books: books)
                    .navigationTitle(list.title)
            } else if let moodTag = moodTag {
                moodTagSection(for: moodTag)
                    .navigationTitle(moodTag.displayName)
            } else {
                loadingView
            }
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private func listSection(for list: ReadingList, books: [Book]) -> some View {
        List {
            Section(header: Text(list.title)) {
                ForEach(books) { book in
                    NavigationLink(destination: BookDetailView(book: book)) {
                        BookCardView(book: book)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func moodTagSection(for moodTag: MoodTag) -> some View {
        let matchingLists = DataLoader.loadSampleData().filter { $0.moodTag == moodTag }

        List {
            ForEach(matchingLists) { list in
                Section(header: Text(list.title)) {
                    ForEach(list.books) { book in
                        NavigationLink(destination: BookDetailView(book: book)) {
                            BookCardView(book: book)
                        }
                    }
                }
            }
        }
    }

    private var loadingView: some View {
        ProgressView("Loading...")
            .onAppear {
                if let listID = listID {
                    readingListManager.fetchListByID(listID) { result in
                        if let fetchedList = result {
                            self.list = fetchedList
                            self.books = readingListManager.booksByListID[listID] ?? []
                        }
                    }
                }
            }
    }

    init(listID: String) {
        self.listID = listID
        self.moodTag = nil
    }

    init(moodTag: MoodTag) {
        self.moodTag = moodTag
        self.listID = nil
    }
}

#Preview {
    PreviewWrapper {
        NavigationStack {
            BookListView(moodTag: .startingOver)
        }
    }
}
