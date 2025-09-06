//
//  BookCardView.swift
//  Clio
//
//  Created by Vivien on 7/4/25.
//

import SwiftUI

struct BookCardView: View {
    let book: Book

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            if let imageURL = book.coverImageURL {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 60, height: 90)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 90)
                            .clipped()
                            .cornerRadius(6)
                    case .failure:
                        PlaceholderImageView()
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                PlaceholderImageView()
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(book.title)
                    .font(.headline)
                Text("by \(book.author)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(book.description)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(3)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
    
    private struct PlaceholderImageView: View {
        var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 60, height: 90)
                Text("No Image")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
    
}

#Preview {
    BookCardView(
      book: Book(
        id: "book123",
        title: "The Midnight Library",
        author: "Matt Haig",
        coverImageName: "book_placeholder",
        description: "A woman finds herself in a library of parallel lives…"
      )
    )
}


