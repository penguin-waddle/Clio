//
//  SavedBooksManager.swift
//  Clio
//
//  Created by Vivien on 7/4/25.

import Foundation
import FirebaseFirestore

final class SavedBooksManager: ObservableObject {

    @Published var savedBooks: [Book] = []

    private let db = Firestore.firestore()

    // Lightweight guest persistence
    private let guestStoreKey = "guest_saved_books_v1"

    // ⚠️ Don't fetch in init. call refresh(...) from the app once session is known.
    init() {}

    // MARK: - Session-aware refresh

    /// Call this whenever session state changes (guest <-> signed-in).
    func refresh(for uid: String?, isGuest: Bool) {
        if isGuest || uid == nil {
            loadGuestSaved()
            return
        }
        fetchFromFirestore(uid: uid!)
    }

    // MARK: - Firestore (signed-in)

    private func fetchFromFirestore(uid: String) {
        db.collection("users").document(uid).collection("books")
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("❌ Error fetching saved books:", error)
                    return
                }
                do {
                    self?.savedBooks = try snapshot?.documents.compactMap {
                        try $0.data(as: Book.self)
                    } ?? []
                } catch {
                    print("❌ Decoding error:", error)
                }
            }
    }

    // MARK: - Queries

    func isSaved(_ book: Book) -> Bool {
        savedBooks.contains(where: { $0.id == book.id })
    }

    // MARK: - Writes

    func saveBook(_ book: Book, uid: String?, isGuest: Bool) {
        if isGuest || uid == nil {
            // guest
            if !savedBooks.contains(where: { $0.id == book.id }) {
                savedBooks.append(book)
                saveGuestSaved()
            }
            return
        }

        // signed in
        do {
            try db.collection("users").document(uid!)
                .collection("books").document(book.id)
                .setData(from: book)
            if !savedBooks.contains(where: { $0.id == book.id }) {
                savedBooks.append(book)
            }
        } catch {
            print("❌ Firestore save failed:", error)
        }
    }

    func removeBook(_ book: Book, uid: String?, isGuest: Bool) {
        if isGuest || uid == nil {
            savedBooks.removeAll { $0.id == book.id }
            saveGuestSaved()
            return
        }

        db.collection("users").document(uid!)
            .collection("books").document(book.id)
            .delete { [weak self] error in
                if let error = error {
                    print("❌ Firestore delete failed:", error)
                } else {
                    self?.savedBooks.removeAll { $0.id == book.id }
                }
            }
    }

    func toggleSave(for book: Book, uid: String?, isGuest: Bool) {
        if isSaved(book) {
            removeBook(book, uid: uid, isGuest: isGuest)
        } else {
            saveBook(book, uid: uid, isGuest: isGuest)
        }
    }

    func saveBookIfNeeded(_ book: Book, uid: String?, isGuest: Bool) {
        guard !isSaved(book) else { return }
        saveBook(book, uid: uid, isGuest: isGuest)
    }

    // MARK: - Guest local cache

    private func loadGuestSaved() {
        guard let data = UserDefaults.standard.data(forKey: guestStoreKey) else {
            savedBooks = []
            return
        }
        do {
            savedBooks = try JSONDecoder().decode([Book].self, from: data)
        } catch {
            print("⚠️ Failed to decode guest saved books:", error)
            savedBooks = []
        }
    }

    private func saveGuestSaved() {
        do {
            let data = try JSONEncoder().encode(savedBooks)
            UserDefaults.standard.set(data, forKey: guestStoreKey)
        } catch {
            print("⚠️ Failed to encode guest saved books:", error)
        }
    }
}


