//
//  ContentView.swift
//  Clio
//
//  Created by Vivien on 7/4/25.
//
import SwiftUI

struct StringWrapper: Identifiable, Equatable {
    let id: String
}

struct ContentView: View {
    @EnvironmentObject var linkRouter: LinkRouter
    @State private var openListID: StringWrapper?
    @State private var openSharedID: StringWrapper?
    
    var body: some View {
        TabView {
            NavigationStack {
                MoodTagView()
            }
            .tabItem {
                Label("Explore", systemImage: "sparkles")
            }

            NavigationStack {
                SearchView()
            }
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }

            NavigationStack {
                ShelfView()
            }
            .tabItem {
                Label("My Shelf", systemImage: "books.vertical")
            }
        }
        .onReceive(linkRouter.$targetListID) { id in
            openListID = id.map { StringWrapper(id: $0) }
        }
        .onReceive(linkRouter.$targetSharedID) { id in
            openSharedID = id.map { StringWrapper(id: $0) }
        }
        .sheet(item: $openListID) { wrapped in
            BookListView(listID: wrapped.id)
        }
        .sheet(item: $openSharedID) { wrapped in
            SharedListLoaderView(shareID: wrapped.id)
        }
    }
}

#Preview {
    PreviewWrapper {
        ContentView()
    }
}


