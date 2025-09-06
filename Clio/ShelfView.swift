//
//  ShelfView.swift
//  Clio
//
//  Created by Vivien on 7/10/25.
//

import SwiftUI

struct ShelfView: View {
    @EnvironmentObject var savedBooks: SavedBooksManager
    @EnvironmentObject var session: SessionManager
    @EnvironmentObject var readingListManager: ReadingListManager

    @State private var selectedList: ReadingList?
    @State private var showListDetail = false
    @State private var showDeleteConfirmation = false

    // list creation
    @State private var showCreateListSheet = false
    @State private var newListTitle = ""
    @State private var newListDescription = ""
    @State private var newCoverImageURL = ""

    // auth gating
    @State private var showAuthAlert = false
    @State private var showAuthSheet = false

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

        // 🔔 Guest gating alert
        .alert("Sign in required", isPresented: $showAuthAlert) {
            Button("Not now", role: .cancel) {}
            Button("Sign In") { showAuthSheet = true }
        } message: {
            Text("Create and manage reading lists when you have an account.")
        }

        // 🗑️ Delete confirmation
        .alert("Delete this list?", isPresented: $showDeleteConfirmation, presenting: selectedList) { list in
            Button("Delete", role: .destructive) {
                readingListManager.deleteList(list)
                selectedList = nil
            }
            Button("Cancel", role: .cancel) { selectedList = nil }
        } message: { list in
            Text("Are you sure you want to delete \"\(list.title)\"?")
        }

        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("➕ Create New List") {
                        if session.isGuest {
                            //  Show alert first (don’t jump into auth)
                            showAuthAlert = true
                        } else {
                            showCreateListSheet = true
                        }
                    }

                    NavigationLink("🔗 Test Shared List View") {
                        SharedListLoaderView(shareID: "abc123XYZ")
                    }

                    if session.isGuest {
                        Button("Sign In") { showAuthSheet = true }
                    } else {
                        Button("Log Out", role: .destructive) { session.signOut() }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .imageScale(.large)
                }
            }
        }
        .onAppear {
            if !session.isGuest {
                readingListManager.fetchLists()
                readingListManager.fetchFollowedLists()
            }
        }

        // sheets
        .sheet(isPresented: $showCreateListSheet) { createListSheet }
        .sheet(isPresented: $showAuthSheet) {
            NavigationStack {
                AuthView()
                    .environmentObject(session)
                    .navigationTitle("Sign In")
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
        .onChange(of: session.uid) {
            if session.uid != nil {
                showAuthSheet = false
            }
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
            } else if !session.isGuest {
                Section {
                    Text("No lists yet. Tap ••• to create your first list.")
                        .foregroundColor(.secondary)
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
                                    ReadingListCardView(list: list, onDelete: nil, onView: nil)
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
            if savedBooks.savedBooks.isEmpty {
                Text(session.isGuest
                     ? "No saved books yet. Save a book from Explore or Search — it’ll stay on this device."
                     : "No saved books yet. Save a book from Explore or Search to see it here.")
                .foregroundColor(.secondary)
            } else {
                ForEach(savedBooks.savedBooks) { book in
                    NavigationLink(destination: BookDetailView(book: book)) {
                        BookCardView(book: book)
                    }
                }
            }
        }
    }

    private var createListSheet: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("New Reading List")
                    .font(.title2).bold()

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
                    let title = newListTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                    let desc  = newListDescription.trimmingCharacters(in: .whitespacesAndNewlines)
                    let img   = newCoverImageURL.trimmingCharacters(in: .whitespacesAndNewlines)

                    guard !title.isEmpty else { return }

                    readingListManager.createList(
                        title: title,
                        description: desc.isEmpty ? nil : desc,
                        coverImageURL: img.isEmpty ? nil : img
                    ) { result in
                        switch result {
                        case .success(let list):
                            print("✅ List created: \(list.title)")
                        case .failure(let error):
                            print("❌ Failed to create list:", error.localizedDescription)
                        }
                    }

                    newListTitle = ""
                    newListDescription = ""
                    newCoverImageURL = ""
                    showCreateListSheet = false
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
}

#Preview {
    PreviewWrapper {
        NavigationStack {
            ShelfView()
        }
    }
}
