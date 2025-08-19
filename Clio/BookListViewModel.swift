//
//  BookListViewModel.swift
//  Clio
//
//  Created by Vivien on 8/19/25.
//

import Foundation

@MainActor
class BookListViewModel: ObservableObject {
    @Published var books: [Book] = []

    func fetchBooks(for keyword: String) async {
        let query = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? keyword
        let urlString = "https://www.googleapis.com/books/v1/volumes?q=\(query)"
        guard let url = URL(string: urlString) else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(GoogleBooksResponse.self, from: data)
            self.books = (decoded.items ?? []).map { $0.toBook() }
        } catch {
            print(error)
        }
    }
}
