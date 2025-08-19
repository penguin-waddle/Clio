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

    var keyword: String {
        switch self {
        case .lost: return "finding direction self help"
        case .hopeful: return "inspirational memoir"
        case .healing: return "healing trauma self help"
        case .nostalgic: return "nostalgic coming of age novel"
        case .growing: return "personal growth"
        case .drifting: return "life purpose self help"
        case .startingOver: return "fresh start self discovery"
        case .grieving: return "grief healing"
        case .reconnecting: return "reconnecting with self"
        }
    }
}

