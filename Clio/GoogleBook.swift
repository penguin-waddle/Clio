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
    var id: String { volumeInfo.title + (volumeInfo.authors?.first ?? "") }
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
