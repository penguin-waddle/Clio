//
//  GoogleBook.swift
//  Clio
//
//  Created by Vivien on 7/11/25.
//

import Foundation

struct GoogleBooksResponse: Codable {
    let items: [GoogleBookItem]?
}

struct GoogleBookItem: Codable, Identifiable {
    let id: String              // <-- real Google Books item id
    let volumeInfo: VolumeInfo
}

struct VolumeInfo: Codable {
    let title: String
    let authors: [String]?
    let description: String?
    let imageLinks: ImageLinks?
    let pageCount: Int?
    let categories: [String]?
    let publishedDate: String?
    let publisher: String?
}

struct ImageLinks: Codable {
    let thumbnail: String?
}

// Keep existing Book model. converter:
extension GoogleBookItem {
    func toBook() -> Book {
        let author = volumeInfo.authors?.first ?? "Unknown Author"
        let thumb = volumeInfo.imageLinks?.thumbnail?
            .replacingOccurrences(of: "http://", with: "https://")
        let url = thumb.flatMap(URL.init(string:))

        return Book(
            id: id,
            title: volumeInfo.title,
            author: author,
            coverImageName: "book_placeholder",
            coverImageURL: url,
            description: volumeInfo.description ?? "",
            pageCount: volumeInfo.pageCount,
            categories: volumeInfo.categories,
            publishedDate: volumeInfo.publishedDate,
            publisher: volumeInfo.publisher
        )
    }
}
