//
//  Book.swift
//  Clio
//
//  Created by Vivien on 7/4/25.
//

import Foundation

struct Book: Identifiable, Codable, Equatable {
    var id: String
    let title: String
    let author: String
    let coverImageName: String // local placeholder
    let coverImageURL: URL?    // Optional remote image
    let description: String
    let pageCount: Int?
    let categories: [String]?
    let publishedDate: String?
    let publisher: String?

    init(
        id: String,
        title: String,
        author: String,
        coverImageName: String,
        coverImageURL: URL? = nil,
        description: String,
        pageCount: Int? = nil,
        categories: [String]? = nil,
        publishedDate: String? = nil,
        publisher: String? = nil
    ) {
        self.id = id
        self.title = title
        self.author = author
        self.coverImageName = coverImageName
        self.coverImageURL = coverImageURL
        self.description = description
        self.pageCount = pageCount
        self.categories = categories
        self.publishedDate = publishedDate
        self.publisher = publisher
    }
}

