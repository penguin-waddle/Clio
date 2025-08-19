//
//  DataLoader.swift
//  Clio
//
//  Created by Vivien on 7/4/25.
//

import Foundation

class DataLoader {
    static func loadSampleData() -> [BookList] {
        guard let url = Bundle.main.url(forResource: "clio_sample_data", withExtension: "json") else {
            print("❌ Failed to find clio_sample_data.json")
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let bookLists = try decoder.decode([BookList].self, from: data)
            return bookLists
        } catch {
            print("❌ Failed to decode clio_sample_data.json: \(error)")
            return []
        }
    }
}

