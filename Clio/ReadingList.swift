//
//  ReadingList.swift
//  Clio
//
//  Created by Vivien on 7/17/25.
//

import Foundation
import FirebaseFirestore

struct ReadingList: Identifiable, Codable {
    @DocumentID var id: String? // Automatically populated when fetching from Firestore
    var title: String
    var createdAt: Date
    var bookIDs: [String]
    var description: String?
    var coverImageURL: String?
    var isPublic: Bool
    var shareID: String
    var ownerUID: String?
}
