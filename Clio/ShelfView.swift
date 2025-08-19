//
//  ShelfView.swift
//  Clio
//
//  Created by Vivien on 7/10/25.
//

import SwiftUI

struct ShelfView: View {
    @EnvironmentObject var savedBooks: SavedBooksManager
    @EnvironmentObject var readingListManager: ReadingListManager
    @State private var selectedList: ReadingList?
    @State private var showListDetail = false
    @State private var showDeleteConfirmation = false

    // list creation
    @State private var showCreateListSheet = false
    @State private var newListTitle = ""
    @State private var newListDescription = ""
    @State private var newCoverImageURL = ""

    var body: some View {
        List {
            myReadingListsSection
            followedListsSection
            savedBooksSection
        }
        .navigationTitle("My Shelf")
        .navigationDestination(isPresented: $showListDetail) {
            if let list = selectedList {
                ReadingListDetailView(list: list)
            }
        }
        .alert("Delete this list?", isPresented: $showDeleteConfirmation, presenting: selectedList) { list in
            Button("Delete", role: .destructive) {
                readingListManager.deleteList(list)
                selectedList = nil
            }
            Button("Cancel", role: .cancel) {
                selectedList = nil
            }
        } message: { list in
            Text("Are you sure you want to delete \"\(list.title)\"?")
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("➕ Create New List") {
                        showCreateListSheet = true
                    }

                    NavigationLink("🔗 Test Shared List View") {
                        SharedListLoaderView(shareID: "abc123XYZ")
                    }

                    Button("Log Out", role: .destructive) {
                        AuthManager.shared.logOut()
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .imageScale(.large)
                }
            }
        }
        .onAppear {
            readingListManager.fetchLists()
            readingListManager.fetchFollowedLists()
        }
        .sheet(isPresented: $showCreateListSheet) {
            createListSheet
        }
    }

    // MARK: - Subviews

    private var myReadingListsSection: some View {
        Group {
            if !readingListManager.readingLists.isEmpty {
                Section(header: Text("My Reading Lists")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(readingListManager.readingLists) { list in
                                ReadingListCardView(
                                    list: list,
                                    onDelete: {
                                        selectedList = list
                                        showDeleteConfirmation = true
                                    },
                                    onView: {
                                        selectedList = list
                                        showListDetail = true
                                    }
                                )
                                .onTapGesture {
                                    selectedList = list
                                    showListDetail = true
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .listRowInsets(EdgeInsets())
                }
            }
        }
    }

    private var followedListsSection: some View {
        Group {
            if !readingListManager.followedLists.isEmpty {
                Section(header: Text("Followed Lists")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(readingListManager.followedLists) { list in
                                NavigationLink(destination: SharedListLoaderView(shareID: list.shareID)) {
                                    ReadingListCardView(
                                        list: list,
                                        onDelete: nil,
                                        onView: nil
                                    )
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .listRowInsets(EdgeInsets())
                }
            }
        }
    }

    private var savedBooksSection: some View {
        Section(header: Text("Saved Books")) {
            ForEach(savedBooks.savedBooks) { book in
                NavigationLink(destination: BookDetailView(book: book)) {
                    BookCardView(book: book)
                }
            }
        }
    }

    private var createListSheet: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("New Reading List")
                    .font(.title2)
                    .bold()

                TextField("List Name", text: $newListTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                TextField("Description (optional)", text: $newListDescription)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                TextField("Cover Image URL (optional)", text: $newCoverImageURL)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                Button("Create") {
                    let trimmedTitle = newListTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                    let trimmedDescription = newListDescription.trimmingCharacters(in: .whitespacesAndNewlines)
                    let trimmedImageURL = newCoverImageURL.trimmingCharacters(in: .whitespacesAndNewlines)

                    if !trimmedTitle.isEmpty {
                        readingListManager.createList(
                            title: trimmedTitle,
                            description: trimmedDescription.isEmpty ? nil : trimmedDescription,
                            coverImageURL: trimmedImageURL.isEmpty ? nil : trimmedImageURL
                        ) { result in
                            switch result {
                            case .success(let list):
                                print("✅ List created: \(list.title)")
                            case .failure(let error):
                                print("❌ Failed to create list:", error.localizedDescription)
                            }
                        }
                            
                        }

                        newListTitle = ""
                        newListDescription = ""
                        newCoverImageURL = ""
                        showCreateListSheet = false
                    }
                }
                .buttonStyle(.borderedProminent)

                Button("Cancel", role: .cancel) {
                    newListTitle = ""
                    newListDescription = ""
                    newCoverImageURL = ""
                    showCreateListSheet = false
                }
            }
            .padding()
            .navigationTitle("Create List")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

#Preview {
    PreviewWrapper {
        NavigationStack {
            ShelfView()
        }
    }
}
