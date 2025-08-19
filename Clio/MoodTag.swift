//
//  MoodTag.swift
//  Clio
//
//  Created by Vivien on 7/4/25.
//

import Foundation

enum MoodTag: String, CaseIterable, Codable, Identifiable {
    case lost
    case hopeful
    case healing
    case nostalgic
    case growing
    case drifting
    case startingOver
    case grieving
    case reconnecting

    var id: String { self.rawValue }

    var displayName: String {
        switch self {
        case .lost: return "Feeling Lost"
        case .hopeful: return "Feeling Hopeful"
        case .healing: return "In Healing"
        case .nostalgic: return "Nostalgic"
        case .growing: return "Growing"
        case .drifting: return "Drifting"
        case .startingOver: return "Starting Over"
        case .grieving: return "Grieving"
        case .reconnecting: return "Reconnecting"
        }
    }
}
