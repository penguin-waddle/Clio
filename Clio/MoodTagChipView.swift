//
//  MoodTagChipView.swift
//  Clio
//
//  Created by Vivien on 7/4/25.
//

import SwiftUI

struct MoodTagChipView: View {
    let moodTag: MoodTag

    var body: some View {
        Text(moodTag.displayName)
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
            .background(Color.accentColor)
            .clipShape(Capsule())
            .shadow(radius: 2, y: 1)
            .accessibilityLabel(Text("Mood: \(moodTag.displayName)"))
    }
}

#Preview {
    PreviewWrapper {
        MoodTagChipView(moodTag: .startingOver)
            .padding()
            .background(Color(.systemBackground))
            .environment(\.colorScheme, .light)
    }
}


