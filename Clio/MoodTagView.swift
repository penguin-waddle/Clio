//
//  MoodTagView.swift
//  Clio
//
//  Created by Vivien on 7/4/25.
//

import SwiftUI

struct MoodTagView: View {
    let moodTags = MoodTag.allCases
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("How are you feeling?")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.leading)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 16) {
                ForEach(moodTags) { mood in
                    NavigationLink(destination: BookListView(moodTag: mood)) {
                        MoodTagChipView(moodTag: mood)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Clio")
    }
}

#Preview {
    PreviewWrapper {
        MoodTagView()
    }
}
