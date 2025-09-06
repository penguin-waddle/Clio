//
//  ContentView.swift
//  Clio
//
//  Created by Vivien on 7/4/25.
//
import SwiftUI

struct StringWrapper: Identifiable, Equatable { let id: String }

struct ContentView: View {
    @EnvironmentObject var linkRouter: LinkRouter

    @State private var openListID: StringWrapper?
    @State private var openSharedID: StringWrapper?

    var body: some View {
        TabView {
            NavigationStack { MoodTagView() }
                .tabItem { Label("Explore", systemImage: "sparkles") }

            NavigationStack { SearchView() }
                .tabItem { Label("Search", systemImage: "magnifyingglass") }

            NavigationStack { ShelfView() }
                .tabItem { Label("My Shelf", systemImage: "books.vertical") }
        }
        // Prefer shared (public) links first if both happen to arrive
        .onReceive(linkRouter.$targetSharedID) { id in
            if let id, openListID == nil && openSharedID == nil {
                openSharedID = StringWrapper(id: id)
            }
        }
        .onReceive(linkRouter.$targetListID) { id in
            if let id, openSharedID == nil && openListID == nil {
                openListID = StringWrapper(id: id)
            }
        }
        .sheet(item: $openSharedID, onDismiss: {
            // clear router state so future links work reliably
            linkRouter.targetSharedID = nil
        }) { wrapped in
            SharedListLoaderView(shareID: wrapped.id)
        }
        .sheet(item: $openListID, onDismiss: {
            linkRouter.targetListID = nil
        }) { wrapped in
            BookListView(listID: wrapped.id)
        }
    }
}

#Preview {
    PreviewWrapper { ContentView() }
}

