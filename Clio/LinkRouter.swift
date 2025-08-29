//
//  LinkRouter.swift
//  Clio
//
//  Created by Vivien on 7/28/25.
//
import Foundation

class LinkRouter: ObservableObject {
    @Published var targetListID: String?      // keep for future internal links
    @Published var targetSharedID: String?    // used for shared lists

    func handleDeepLink(_ url: URL) {
        print("📬 Received URL: \(url.absoluteString)")

        // 1) Custom scheme host first (e.g. clioapp://list/<id>)
        if url.scheme?.lowercased() == "clioapp" {
            let host = url.host?.lowercased() ?? ""
            let parts = url.pathComponents.filter { $0 != "/" } // e.g. ["3xLSmB0UwT"] or ["list","3xLSmB0UwT"]

            // Case A: host is "list" or "shared" and first path component is the id
            if (host == "list" || host == "shared"), let id = parts.first, !id.isEmpty {
                targetSharedID = id
                print("📡 Deep linked to SHARED list via host: \(id)")
                return
            }

            // Case B: host is something else (or nil) and first path component is "list"/"shared"
            if parts.count >= 2 {
                let first = parts[0].lowercased()
                let id = parts[1]
                if first == "list" || first == "shared" {
                    targetSharedID = id
                    print("📡 Deep linked to SHARED list via path: \(id)")
                    return
                }
            }
        }

        // 2) Handle web links with hash routing: https://.../#/list/<id>
        if let frag = URLComponents(url: url, resolvingAgainstBaseURL: false)?.fragment {
            // frag looks like: "/list/<id>" or "list/<id>"
            let trimmed = frag.hasPrefix("/") ? String(frag.dropFirst()) : frag
            let parts = trimmed.split(separator: "/").map(String.init) // ["list","<id>"]

            if parts.count >= 2 {
                let first = parts[0].lowercased()
                let id = parts[1]
                if first == "list" || first == "shared" {
                    targetSharedID = id
                    print("📡 Deep linked to SHARED list via web hash: \(id)")
                    return
                }
            }
        }

        print("ℹ️ Deep link not recognized: \(url.absoluteString)")
    }
}
