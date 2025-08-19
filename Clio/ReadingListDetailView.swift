//
//  ReadingListDetailView.swift
//  Clio
//
//  Created by Vivien on 7/17/25.
//

import SwiftUI

struct ReadingListDetailView: View {
    let list: ReadingList
    @EnvironmentObject var readingListManager: ReadingListManager

    @State private var isLoading = true

    var booksInList: [Book] {
        readingListManager.booksByListID[list.id ?? ""] ?? []
    }

    var body: some View {
        Group {
            if isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                    Text("Loading books...")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if booksInList.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "books.vertical")
                        .font(.system(size: 40))
                        .foregroundColor(.gray.opacity(0.6))
                    Text("No books in this list yet.")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(booksInList) { book in
                    NavigationLink(destination: BookDetailView(book: book)) {
                        BookCardView(book: book)
                    }
                    .contextMenu {
                        Button(role: .destructive) {
                            readingListManager.removeBook(book.id, from: list)
                        } label: {
                            Label("Remove from List", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .navigationTitle(list.title)
        .onAppear {
            isLoading = true
            readingListManager.fetchBooks(for: list) {
                isLoading = false
            }
        }
    }
}

#Preview {
    PreviewWrapper {
        NavigationStack {
            ReadingListDetailView(
                list: ReadingList(
                    id: "sample-id",
                    title: "Favorites",
                    createdAt: Date(),
                    bookIDs: ["1", "2"],
                    description: "All-time favs",
                    coverImageURL: nil,
                    isPublic: true,
                    shareID: "public456"
                )
            )
        }
    }
}
