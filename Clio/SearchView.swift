//
//  SearchView.swift
//  Clio
//
//  Created by Vivien on 7/10/25.
//

import SwiftUI
import FirebaseFirestore

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @EnvironmentObject var readingListManager: ReadingListManager

    var body: some View {
        List {
            // 🔄 Show loading spinner
            if viewModel.isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            } else {
                // 📚 Search results
                ForEach(viewModel.results) { item in
                    NavigationLink(destination: BookDetailView(book: item.toBook())) {
                        BookCardView(book: item.toBook())
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Search")
        .searchable(text: $viewModel.query, prompt: "Search books…")
        .onSubmit(of: .search) {
            Task { await viewModel.searchBooks() }
        }
    }
}

extension GoogleBookItem {
    func toBook() -> Book {
        let urlString = volumeInfo.imageLinks?.thumbnail?.replacingOccurrences(of: "http://", with: "https://")
        let url = URL(string: urlString ?? "")
        return Book(
            id: self.id,
            title: volumeInfo.title,
            author: volumeInfo.authors?.first ?? "Unknown Author",
            coverImageName: "book_placeholder",
            coverImageURL: url,
            description: volumeInfo.description ?? "No description",
            pageCount: volumeInfo.pageCount,
            categories: volumeInfo.categories,
            publishedDate: volumeInfo.publishedDate,
            publisher: volumeInfo.publisher
        )
    }
}

#Preview {
    PreviewWrapper {
        NavigationStack {
            SearchView()
        }
    }
}
