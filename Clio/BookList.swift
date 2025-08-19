//
//  BookList.swift
//  Clio
//
//  Created by Vivien on 7/4/25.
//

import Foundation

struct BookList: Identifiable, Codable {
    let id: UUID
    let title: String
    let moodTag: MoodTag
    let description: String
    let books: [Book]
}

