//
//  ReadingListCardView.swift
//  Clio
//
//  Created by Vivien on 7/17/25.
//

import SwiftUI

import SwiftUI

struct ReadingListCardView: View {
    let list: ReadingList
    let onDelete: (() -> Void)?
    let onView: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(list.title)
                .font(.headline)
                .foregroundColor(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            Text("\(list.bookIDs.count) book\(list.bookIDs.count == 1 ? "" : "s")")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color(.separator), lineWidth: 0.5)
        )
        .frame(width: 180, height: 100)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
        .contextMenu {
            Button("View List") {
                onView?()
            }
            
            Button("Delete List", role: .destructive) {
                onDelete?()
            }
        }
    }
}

#Preview {
    PreviewWrapper {
        ReadingListCardView(
            list: ReadingList(
                id: "sample-id",
                title: "Summer Reading",
                createdAt: Date(),
                bookIDs: ["book1", "book2", "book3"],
                description: "Books for beach and travel days",
                coverImageURL: nil,
                isPublic: true,
                shareID: "share123"
            ),
            onDelete: {},
            onView: {}
        )
    }
}
