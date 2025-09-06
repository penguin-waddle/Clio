//
//  SharedListView.swift
//  Clio
//
//  Created by Vivien on 7/21/25.
//

import SwiftUI
import AlertToast

struct SharedListView: View {
    @EnvironmentObject var readingListManager: ReadingListManager
    @EnvironmentObject var session: SessionManager
    @State private var isFollowing = false
    @State private var showToast = false
    @State private var toastMessage = "Added to shelf"
    
    let list: ReadingList
    let books: [Book]
    
    var shareURL: URL {
        // Use hash route
        URL(string: "https://clioapp-1dc1f.web.app/#/list/\(list.shareID)")!
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                // 🔹 Optional Cover Image
                if let imageURL = list.coverImageURL, let url = URL(string: imageURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(height: 200)

                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(height: 200)
                                .clipped()
                                .cornerRadius(12)

                        case .failure(_):
                            Rectangle()
                                .fill(Color.gray.opacity(0.1))
                                .frame(height: 200)
                                .overlay(
                                    Image(systemName: "photo")
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray)
                                )
                                .cornerRadius(12)

                        @unknown default:
                            EmptyView()
                        }
                    }
                }

                // 🔹 Title & Description
                VStack(alignment: .leading, spacing: 4) {
                    Text(list.title)
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    if let description = list.description, !description.isEmpty {
                        Text(description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                
                Button(action: {
                                    guard !session.isGuest else {
                                        toastMessage = "Sign in to add lists to your shelf"
                                        showToast = true
                                        return
                                    }
                                    if isFollowing {
                                        readingListManager.unfollowSharedList(list)
                                        toastMessage = "Removed from shelf"
                                    } else {
                                        readingListManager.followSharedList(list)
                                        toastMessage = "Added to shelf"
                                    }
                                    isFollowing.toggle()
                                    showToast = true
                                }) {
                    HStack {
                        Image(systemName: isFollowing ? "bookmark.slash" : "bookmark")
                        Text(isFollowing ? "Remove from Shelf" : "Add to My Shelf")
                    }
                    .fontWeight(.medium)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(Color.accentColor.opacity(0.1))
                    .foregroundColor(.accentColor)
                    .cornerRadius(8)
                    .padding(.horizontal)
                }
                .transition(.opacity)

                Divider()

                // 🔹 Books
                if books.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "book.closed")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        Text("This list doesn’t have any books yet.")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                } else {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Books in this list")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding(.top, 8)
                            .padding(.horizontal)

                        ForEach(books.indices, id: \.self) { index in
                            BookCardView(book: books[index])
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(10)
                                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                                .padding(.horizontal)

                            if index < books.count - 1 {
                                Divider()
                                    .padding(.horizontal)
                            }
                        }
                    }
                }

            }
            .padding(.top, 16)
        }
        .onAppear {
            isFollowing = readingListManager.isFollowingSharedList(list)
        }
        .toast(isPresenting: $showToast) {
            AlertToast(type: .complete(.accentColor), title: toastMessage)
        }
        .navigationTitle("Shared List")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                ShareLink(item: shareURL) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
                .contextMenu {
                    Button {
                        UIPasteboard.general.string = shareURL.absoluteString
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    } label: {
                        Label("Copy Link", systemImage: "doc.on.doc")
                    }
                }
            }
        }
        .background(
            ZStack(alignment: .top) {
                Color(.systemGroupedBackground)

                // 🔹 Subtle top shadow
                Color(.separator)
                    .frame(height: 0.5)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)
                    .offset(y: -1) // nudges it up slightly to sit below nav bar
            }
        )
    }
}

#Preview {
    let sampleList = ReadingList(
        id: "preview-id",
        title: "Summer Reads",
        createdAt: Date(),
        bookIDs: ["book1", "book2"],
        description: "A few books I want to finish before fall 🍂",
        coverImageURL: nil,
        isPublic: true,
        shareID: "sampleXYZ"
    )

    let sampleBooks = [
        Book(
            id: "book1",
            title: "Sample Book One",
            author: "Author A",
            coverImageName: "book_placeholder",
            coverImageURL: nil,
            description: "A test description.",
            pageCount: 200,
            categories: ["Fiction"],
            publishedDate: "2020",
            publisher: "Publisher A"
        ),
        Book(
            id: "book2",
            title: "Sample Book Two",
            author: "Author B",
            coverImageName: "book_placeholder",
            coverImageURL: nil,
            description: "Another test description.",
            pageCount: 300,
            categories: ["Fantasy"],
            publishedDate: "2021",
            publisher: "Publisher B"
        )
    ]
    
    let readingListManager = ReadingListManager()
    readingListManager.followedLists = [sampleList] // simulate following

    return NavigationStack {
        SharedListView(list: sampleList, books: sampleBooks)
            .environmentObject(readingListManager)
    }
}
