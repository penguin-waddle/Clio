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

    @EnvironmentObject var session: SessionManager
    @EnvironmentObject var readingListManager: ReadingListManager

    @State private var list: ReadingList?
    @State private var books: [Book] = []
    @StateObject private var viewModel = BookListViewModel()

    var body: some View {
        Group {
            if let list = list {
                listSection(for: list, books: books)
                    .navigationTitle(list.title)
            } else if let moodTag = moodTag {
                moodTagSection(for: moodTag)
                    .navigationTitle(moodTag.displayName)
            } else {
                loadingOrMessageView
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
        if viewModel.books.isEmpty {
            ProgressView("Loading...")
                .task {
                    // fetch fresh results for the mood keyword
                    await viewModel.fetchBooks(for: moodTag.keyword)
                }
        } else {
            List {
                ForEach(viewModel.books) { book in
                    NavigationLink(destination: BookDetailView(book: book)) {
                        BookCardView(book: book)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var loadingOrMessageView: some View {
        if let listID = listID {
            if session.isGuest {
                VStack(spacing: 12) {
                    Image(systemName: "person.crop.circle.badge.questionmark")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text("Sign in to view your private lists.")
                        .foregroundColor(.secondary)
                }
                .onAppear {
                    // Don’t attempt Firestore fetch in guest mode
                    self.list = nil
                    self.books = []
                }
            } else {
                ProgressView("Loading…")
                    .onAppear {
                        readingListManager.fetchListByID(listID) { result in
                            guard let fetched = result else { return }
                            self.list = fetched
                            self.books = readingListManager.booksByListID[listID] ?? []
                        }
                    }
            }
        } else {
            ProgressView("Loading…")
        }
    }

    // MARK: - Inits

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
