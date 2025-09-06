//
//  ListSelectionView.swift
//  Clio
//
//  Created by Vivien on 7/18/25.
//
import SwiftUI

struct ListSelectionView: View {
    let book: Book
    let fullBook: Book?

    @EnvironmentObject var readingListManager: ReadingListManager
    @EnvironmentObject var session: SessionManager

    @State private var showAuthPrompt = false

    var body: some View {
        List {
            if readingListManager.readingLists.isEmpty {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(session.isGuest
                             ? "Sign in to create reading lists."
                             : "No lists yet. Create one from your shelf!")
                            .foregroundColor(.secondary)
                        if session.isGuest {
                            Button {
                                showAuthPrompt = true
                            } label: {
                                Label("Sign in / Create account", systemImage: "person.crop.circle.badge.plus")
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            } else {
                ForEach(readingListManager.readingLists) { list in
                    HStack {
                        Text(list.title)
                        Spacer()
                        Image(systemName: list.bookIDs.contains(book.id) ? "minus.circle.fill" : "plus.circle")
                            .foregroundColor(list.bookIDs.contains(book.id) ? .red : .accentColor)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if session.isGuest {
                            showAuthPrompt = true
                            return
                        }
                        if list.bookIDs.contains(book.id) {
                            readingListManager.removeBook(book.id, from: list)
                        } else {
                            readingListManager.addBook(book.id, to: list, fullBook: book)
                        }
                    }
                    .disabled(session.isGuest)
                    .opacity(session.isGuest ? 0.5 : 1.0)
                }
            }
        }
        .navigationTitle("Select Lists")
        .onAppear {
            readingListManager.fetchLists() // guests get [], signed-in loads normally
        }
        .alert("Sign in to use reading lists", isPresented: $showAuthPrompt) {
            // You can present AuthView here if this view is inside a NavigationStack
            // or just offer a dismiss. Keeping it simple for now:
            Button("OK", role: .cancel) {}
        } message: {
            Text("Create an account (or log in) to add books to your reading lists.")
        }
    }
}

#Preview {
    let manager = ReadingListManager()
    manager.readingLists = [
        ReadingList(
            id: "1",
            title: "Favorites",
            createdAt: Date(),
            bookIDs: ["book123"],
            description: nil,
            coverImageURL: nil,
            isPublic: true,
            shareID: "abc123",
            ownerUID: "owner"
        ),
        ReadingList(
            id: "2",
            title: "TBR",
            createdAt: Date(),
            bookIDs: [],
            description: nil,
            coverImageURL: nil,
            isPublic: false,
            shareID: "def456",
            ownerUID: "owner"
        )
    ]

    let sampleBook = Book(
        id: "book123",
        title: "Sample Book",
        author: "Sample Author",
        coverImageName: "book_placeholder",
        coverImageURL: nil,
        description: "This is a sample book.",
        pageCount: 123,
        categories: ["Fantasy"],
        publishedDate: "2020",
        publisher: "Sample Publisher"
    )

    return PreviewWrapper(readingListManager: manager) {
        NavigationStack {
            ListSelectionView(book: sampleBook, fullBook: sampleBook)
                .environmentObject(SessionManager())
        }
    }
}
