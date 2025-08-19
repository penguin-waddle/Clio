//
//  SavedBooksManager.swift
//  Clio
//
//  Created by Vivien on 7/4/25.
//
import FirebaseFirestore
import Foundation

class SavedBooksManager: ObservableObject {
    
    init() {
        fetchSavedBooks()
    }
    
    @Published var savedBooks: [Book] = []
    
    private var db = Firestore.firestore()
    private var uid: String? {
        UserDefaults.standard.string(forKey: "uid")
    }

    private var booksCollection: CollectionReference? {
        guard let uid = uid else { return nil }
        return db.collection("users").document(uid).collection("books")
    }
    
    func fetchSavedBooks() {
        booksCollection?.getDocuments { [weak self] snapshot, error in
            if let error = error {
                print("❌ Error fetching saved books: \(error)")
                return
            }

            do {
                self?.savedBooks = try snapshot?.documents.compactMap {
                    try $0.data(as: Book.self)
                } ?? []
            } catch {
                print("❌ Decoding error: \(error)")
            }
        }
    }
    
    func isSaved(_ book: Book) -> Bool {
        savedBooks.contains(where: { $0.id == book.id })
    }
    
    func saveBook(_ book: Book) {
        guard let booksCollection = booksCollection else { return }

        do {
            try booksCollection.document(book.id).setData(from: book)
            savedBooks.append(book)
        } catch {
            print("❌ Firestore save failed: \(error)")
        }
    }
    
    func removeBook(_ book: Book) {
        guard let booksCollection = booksCollection else { return }

        booksCollection.document(book.id).delete { error in
            if let error = error {
                print("❌ Firestore delete failed: \(error)")
            } else {
                self.savedBooks.removeAll { $0.id == book.id }
            }
        }
    }
    
    func toggleSave(for book: Book) {
        if isSaved(book) {
            removeBook(book)
        } else {
            saveBook(book)
        }
    }
    
    func saveBookIfNeeded(_ book: Book) {
        guard !savedBooks.contains(where: { $0.id == book.id }) else { return }
        saveBook(book)
    }
    
}


