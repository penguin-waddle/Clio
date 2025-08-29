//
//  PublicBookPreview.swift
//  Clio
//
//  Created by Vivien on 8/28/25.
//

import Foundation

struct PublicBookPreview: Codable, Identifiable {
    let id: String
    let title: String
    let author: String
    let coverImageURL: String?
}
