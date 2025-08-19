//
//  SharedListLoaderView.swift
//  Clio
//
//  Created by Vivien on 7/21/25.
//

import SwiftUI

struct SharedListLoaderView: View {
    let shareID: String
    @State private var sharedList: ReadingList?
    @State private var books: [Book] = []
    @State private var isLoading = true
    @State private var notFound = false

    @EnvironmentObject var readingListManager: ReadingListManager

    var body: some View {
        Group {
            if isLoading {
                VStack(spacing: 12) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .accentColor))
                    Text("Loading...")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else if notFound {
                VStack(spacing: 12) {
                    Image(systemName: "xmark.circle")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                    Text("List not found or is private.")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else if let list = sharedList {
                SharedListView(list: list, books: books)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.3), value: books)
            }
        }
        .navigationTitle("Shared List")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            readingListManager.fetchListByShareID(shareID) { result in
                if let list = result {
                    self.sharedList = list
                    readingListManager.fetchBooks(for: list) {
                        self.books = readingListManager.booksByListID[list.id ?? ""] ?? []
                        self.isLoading = false
                    }
                } else {
                    self.isLoading = false
                    self.notFound = true
                }
            }
        }
    }
}

#Preview {
    let mockManager = ReadingListManager()

    return NavigationStack {
        SharedListLoaderView(shareID: "abc123XYZ")
            .environmentObject(mockManager)
    }
}
