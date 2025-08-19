//
//  BookDetailView.swift
//  Clio
//
//  Created by Vivien on 7/4/25.
//

import SwiftUI

struct BookDetailView: View {
    let book: Book
    @EnvironmentObject var savedBooks: SavedBooksManager
    @State private var showListSelector = false
    @EnvironmentObject var readingListManager: ReadingListManager

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(book.title)
                    .font(.largeTitle)
                Text("by \(book.author)")
                    .font(.title3)
                    .foregroundColor(.secondary)
                if let imageURL = book.coverImageURL {
                    AsyncImage(url: imageURL) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(height: 200)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .cornerRadius(10)
                        case .failure:
                            PlaceholderImageDetailView()
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    PlaceholderImageDetailView()
                }
                Text(book.description)
                    .font(.body)
                
                Group {
                    if let publisher = book.publisher {
                        Text("Publisher: \(publisher)")
                            .font(.subheadline)
                    }

                    if let date = book.publishedDate {
                        Text("Published: \(date)")
                            .font(.subheadline)
                    }

                    if let pages = book.pageCount {
                        Text("Pages: \(pages)")
                            .font(.subheadline)
                    }

                    if let categories = book.categories, !categories.isEmpty {
                        Text("Genre: \(categories.joined(separator: ", "))")
                            .font(.subheadline)
                    }
                }
                .foregroundColor(.secondary)

                Button(savedBooks.isSaved(book) ? "Remove from Shelf" : "Save to Shelf") {
                        savedBooks.toggleSave(for: book)
                    }
                    .padding()
                    .background(savedBooks.isSaved(book) ? Color.gray : Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                
                Button("➕ Add to Reading List") {
                    showListSelector = true
                }
                .sheet(isPresented: $showListSelector) {
                    ListSelectionView(book: book, fullBook: book)
                        .presentationDetents([.medium, .large])
                }
            }
            .padding()
        }
        .navigationTitle(book.title)
    }
    
    private struct PlaceholderImageDetailView: View {
        var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 200)
                Text("No Image")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
    
}

#Preview {
    PreviewWrapper {
        NavigationStack {
            BookDetailView(book: Book(
                id: "book123",
                title: "Preview Title",
                author: "Preview Author",
                coverImageName: "book_placeholder",
                coverImageURL: nil,
                description: "This is a preview of a book used in SwiftUI.",
                pageCount: 256,
                categories: ["Fiction", "Adventure"],
                publishedDate: "2021-09-15",
                publisher: "Preview Press"
            ))
        }
    }
}



