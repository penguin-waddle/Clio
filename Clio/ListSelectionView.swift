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

    var body: some View {
        List {
            ForEach(readingListManager.readingLists) { list in
                HStack {
                    Text(list.title)
                    Spacer()
                    Image(systemName: list.bookIDs.contains(book.id) ? "minus.circle.fill" : "plus.circle")
                        .foregroundColor(list.bookIDs.contains(book.id) ? .red : .accentColor)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if list.bookIDs.contains(book.id) {
                        readingListManager.removeBook(book.id, from: list)
                    } else {
                        readingListManager.addBook(book.id, to: list, fullBook: book)
                    }
                }
            }
        }
        .navigationTitle("Select Lists")
        .onAppear {
            readingListManager.fetchLists()
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
            shareID: "abc123"
        ),
        ReadingList(
            id: "2",
            title: "TBR",
            createdAt: Date(),
            bookIDs: [],
            description: nil,
            coverImageURL: nil,
            isPublic: false,
            shareID: "def456"
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
        }
    }
}
