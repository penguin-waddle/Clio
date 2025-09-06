//
//  SearchView.swift
//  Clio
//
//  Created by Vivien on 7/10/25.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()

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

#Preview {
    PreviewWrapper {
        NavigationStack {
            SearchView()
        }
    }
}
