import Foundation
import SwiftUI

struct PriorityItem: Identifiable, Codable {
    let id: UUID
    var name: String
    var x: CGFloat
    var y: CGFloat
    var colorName: String
    var addedDate: Date

    var color: Color {
        switch colorName {
        case "red": return .red
        case "orange": return .orange
        case "green": return .green
        case "blue": return .blue
        case "purple": return .purple
        case "pink": return .pink
        case "yellow": return .yellow
        default: return .gray
        }
    }

    init(name: String, x: CGFloat = 0.25, y: CGFloat = 0.25, colorName: String = "red", addedDate: Date = Date()) {
        self.id = UUID()
        self.name = name
        self.x = x
        self.y = y
        self.colorName = colorName
        self.addedDate = addedDate
    }

    // Backward-compatible decoding: if addedDate is missing in older saves, default to now.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try c.decode(UUID.self, forKey: .id)
        self.name = try c.decode(String.self, forKey: .name)
        self.x = try c.decode(CGFloat.self, forKey: .x)
        self.y = try c.decode(CGFloat.self, forKey: .y)
        self.colorName = try c.decode(String.self, forKey: .colorName)
        self.addedDate = try c.decodeIfPresent(Date.self, forKey: .addedDate) ?? Date()
    }

    private enum CodingKeys: String, CodingKey {
        case id, name, x, y, colorName, addedDate
    }

    // Anger progression based on age + position.
    // Position (0,0) = top-left = most urgent + most important → full anger in 3 days (72h).
    // Position (1,1) = bottom-right = least urgent + least important → full anger in 2 weeks (336h).
    func angerLevel(now: Date = Date()) -> Double {
        let urgency = Double(1.0 - x)
        let importance = Double(1.0 - y)
        let priority = (urgency + importance) / 2.0  // 0.0 … 1.0

        let minHours = 72.0    // top-left: 3 days
        let maxHours = 336.0   // bottom-right: 2 weeks
        let hoursToMax = maxHours - priority * (maxHours - minHours)

        let hoursElapsed = now.timeIntervalSince(addedDate) / 3600.0
        return min(max(hoursElapsed / hoursToMax, 0.0), 1.0)
    }

    func faceEmoji(now: Date = Date()) -> String {
        let anger = angerLevel(now: now)
        switch anger {
        case ..<0.2:  return "😊"
        case ..<0.4:  return "🙂"
        case ..<0.6:  return "😐"
        case ..<0.8:  return "😠"
        default:      return "😡"
        }
    }
}

struct IdeaItem: Identifiable, Codable {
    let id: UUID
    var name: String
    var addedDate: Date
    var notes: String

    init(name: String, notes: String = "") {
        self.id = UUID()
        self.name = name
        self.addedDate = Date()
        self.notes = notes
    }

    // Backward-compatible decoding: `notes` is absent in older saves.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try c.decode(UUID.self, forKey: .id)
        self.name = try c.decode(String.self, forKey: .name)
        self.addedDate = try c.decode(Date.self, forKey: .addedDate)
        self.notes = try c.decodeIfPresent(String.self, forKey: .notes) ?? ""
    }

    private enum CodingKeys: String, CodingKey {
        case id, name, addedDate, notes
    }
}

struct DeletedItem: Identifiable, Codable {
    let id: UUID
    let name: String
    let colorName: String
    let addedDate: Date
    let deletedDate: Date

    var color: Color {
        switch colorName {
        case "red": return .red
        case "orange": return .orange
        case "green": return .green
        case "blue": return .blue
        case "purple": return .purple
        case "pink": return .pink
        case "yellow": return .yellow
        default: return .gray
        }
    }
}
