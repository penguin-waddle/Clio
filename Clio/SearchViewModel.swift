//
//  SearchViewModel.swift
//  Clio
//
//  Created by Vivien on 7/11/25.
//

import Foundation

@MainActor
class SearchViewModel: ObservableObject {
    @Published var query = ""
    @Published var results: [GoogleBookItem] = []
    @Published var isLoading = false

    func searchBooks() async {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        isLoading = true

        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://www.googleapis.com/books/v1/volumes?q=\(encodedQuery)&maxResults=20"

        guard let url = URL(string: urlString) else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(GoogleBooksResponse.self, from: data)
            self.results = decoded.items ?? []
        } catch {
            print("❌ Error fetching books: \(error)")
            self.results = []
        }

        isLoading = false
    }
}
