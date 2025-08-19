//
//  ReadingListManager.swift
//  Clio
//
//  Created by Vivien on 7/17/25.
//
import Foundation
import FirebaseFirestore
import FirebaseAuth

class ReadingListManager: ObservableObject {
    @Published var readingLists: [ReadingList] = []
    @Published var booksByListID: [String: [Book]] = [:]
    @Published var followedLists: [ReadingList] = []

    private var db = Firestore.firestore()
    private var uid: String? {
        UserDefaults.standard.string(forKey: "uid")
    }

    private var readingListsCollection: CollectionReference? {
        guard let uid = uid else { return nil }
        return db.collection("users").document(uid).collection("readingLists")
    }
    
    private var savedBooksManager: SavedBooksManager?
    
    func configure(savedBooksManager: SavedBooksManager) {
        self.savedBooksManager = savedBooksManager
    }

    func fetchLists() {
        readingListsCollection?.order(by: "createdAt", descending: true).getDocuments { snapshot, error in
            if let error = error {
                print("❌ Error fetching lists: \(error)")
                return
            }

            do {
                self.readingLists = try snapshot?.documents.compactMap {
                    try $0.data(as: ReadingList.self)
                } ?? []

                // Optional: preload books
                self.readingLists.forEach { self.fetchBooks(for: $0) }

            } catch {
                print("❌ Decoding error: \(error)")
            }
        }
    }

    func fetchBooks(for list: ReadingList, completion: (() -> Void)? = nil) {
        guard let listID = list.id, let uid = uid else {
            completion?()
            return
        }

        let booksRef = db.collection("users").document(uid)
            .collection("readingLists").document(listID)
            .collection("books")

        booksRef.getDocuments { snapshot, error in
            if let error = error {
                print("❌ Failed to fetch books for list: \(error)")
                self.booksByListID[listID] = []
                completion?()
                return
            }

            let books = snapshot?.documents.compactMap {
                try? $0.data(as: Book.self)
            } ?? []

            self.booksByListID[listID] = books
            completion?()
        }
    }

    func createList(
        title: String,
        description: String?,
        coverImageURL: String?,
        completion: @escaping (Result<ReadingList, Error>) -> Void
    ) {
        let shareID = generateShareID(length: 10)
        let timestamp = Date()

        let newList = ReadingList(
            title: title,
            createdAt: timestamp,
            bookIDs: [],
            description: description,
            coverImageURL: coverImageURL,
            isPublic: true,
            shareID: shareID
        )

        guard let userID = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "ReadingListManager", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in."])))
            return
        }

        let docRef = db.collection("users").document(userID)
            .collection("readingLists").document(shareID)

        do {
            try docRef.setData(from: newList) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    DispatchQueue.main.async {
                        self.readingLists.append(newList)
                        completion(.success(newList))
                    }
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    private func generateShareID(length: Int = 8) -> String {
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).compactMap { _ in characters.randomElement() })
    }
    
    private var followedListsCollection: CollectionReference? {
        guard let uid = uid else { return nil }
        return db.collection("users").document(uid).collection("followedLists")
    }
    
    func followSharedList(_ sharedList: ReadingList) {
        let shareID = sharedList.shareID

        let ref = followedListsCollection?.document(shareID)
        do {
            try ref?.setData(from: sharedList)
            print("✅ Followed shared list.")
            fetchFollowedLists()
        } catch {
            print("❌ Failed to save followed list: \(error)")
        }
    }
    
    func fetchFollowedLists() {
        followedListsCollection?.getDocuments { snapshot, error in
            if let error = error {
                print("❌ Error fetching followed lists: \(error)")
                return
            }

            do {
                self.followedLists = try snapshot?.documents.compactMap {
                    try $0.data(as: ReadingList.self)
                } ?? []

                self.followedLists.forEach { self.fetchBooks(for: $0) }

            } catch {
                print("❌ Decoding error for followed lists: \(error)")
            }
        }
    }
    
    func isFollowingSharedList(_ sharedList: ReadingList) -> Bool {
        let shareID = sharedList.shareID
        return followedLists.contains(where: { $0.shareID == shareID })
    }
    
    func unfollowSharedList(_ sharedList: ReadingList) {
        let shareID = sharedList.shareID

        followedListsCollection?.document(shareID).delete { error in
            if let error = error {
                print("❌ Failed to unfollow list: \(error)")
            } else {
                self.followedLists.removeAll { $0.shareID == shareID }
                print("✅ Unfollowed shared list.")
            }
        }
    }
    
    func fetchListByID(_ id: String, completion: @escaping (ReadingList?) -> Void) {
        readingListsCollection?.document(id).getDocument { snapshot, error in
            if let error = error {
                print("❌ Error fetching list by ID: \(error)")
                completion(nil)
                return
            }

            guard let snapshot = snapshot, snapshot.exists else {
                completion(nil)
                return
            }

            do {
                let list = try snapshot.data(as: ReadingList.self)
                self.fetchBooks(for: list) {
                    completion(list)
                }
            } catch {
                print("❌ Decoding error: \(error)")
                completion(nil)
            }
        }
    }
    
    func fetchListByShareID(_ shareID: String, completion: @escaping (ReadingList?) -> Void) {
        db.collectionGroup("readingLists")
            .whereField("shareID", isEqualTo: shareID)
            .whereField("isPublic", isEqualTo: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Failed to fetch shared list: \(error)")
                    completion(nil)
                    return
                }

                guard let doc = snapshot?.documents.first else {
                    completion(nil)
                    return
                }

                do {
                    let list = try doc.data(as: ReadingList.self)
                    completion(list)
                } catch {
                    print("❌ Decoding error: \(error)")
                    completion(nil)
                }
            }
    }

    func deleteList(_ list: ReadingList) {
        guard let id = list.id else { return }
        readingListsCollection?.document(id).delete { error in
            if let error = error {
                print("❌ Failed to delete list: \(error)")
            } else {
                self.readingLists.removeAll { $0.id == id }
            }
        }
    }

    func addBook(_ bookID: String, to list: ReadingList, fullBook: Book) {
        guard let id = list.id, let uid = uid else { return }

        // Save book to subcollection
        let listBookRef = db.collection("users").document(uid)
            .collection("readingLists").document(id)
            .collection("books").document(bookID)

        do {
            try listBookRef.setData(from: fullBook)
        } catch {
            print("❌ Failed to store book in list: \(error)")
        }

        // Also update the bookIDs field
        readingListsCollection?.document(id).updateData([
            "bookIDs": FieldValue.arrayUnion([bookID])
        ]) { error in
            if let error = error {
                print("❌ Failed to add book ID to list: \(error)")
            } else {
                self.fetchLists()
            }
        }
    }
    
    func removeBook(_ bookID: String, from list: ReadingList) {
        guard let id = list.id, let uid = uid else { return }

        // Remove book document from subcollection
        db.collection("users").document(uid)
            .collection("readingLists").document(id)
            .collection("books").document(bookID).delete()

        // Remove book ID from bookIDs array
        readingListsCollection?.document(id).updateData([
            "bookIDs": FieldValue.arrayRemove([bookID])
        ]) { error in
            if let error = error {
                print("❌ Failed to remove book ID: \(error)")
            } else {
                self.fetchLists()
            }
        }
    }
}

