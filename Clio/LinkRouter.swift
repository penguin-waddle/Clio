//
//  LinkRouter.swift
//  Clio
//
//  Created by Vivien on 7/28/25.
//

import Foundation

class LinkRouter: ObservableObject {
    @Published var targetListID: String?
    @Published var targetSharedID: String? 

    func handleDeepLink(_ url: URL) {
        let parts = url.pathComponents.filter { $0 != "/" }

        if parts.count >= 2 {
            if parts[0] == "list" {
                targetListID = parts[1]
                print("📡 Deep linked to list ID: \(parts[1])")
            } else if parts[0] == "shared" {
                targetSharedID = parts[1]
                print("📡 Deep linked to shared list with shareID: \(parts[1])")
            }
        }
    }
}
