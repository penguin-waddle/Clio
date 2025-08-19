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
            .background(Color.blue)
            .clipShape(Capsule())
            .shadow(radius: 2)
    }
}

#Preview {
    PreviewWrapper {
        MoodTagChipView(moodTag: .startingOver)
    }
}


