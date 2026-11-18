import Foundation
import SwiftUI

class ItemStore: ObservableObject {
    @Published var items: [PriorityItem] = []
    @Published var deletedItems: [DeletedItem] = []
    @Published var ideas: [IdeaItem] = []

    private let fileURL: URL
    private let deletedFileURL: URL
    private let ideasFileURL: URL

    init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let dir = appSupport.appendingPathComponent("Prioritizer")
        self.fileURL = dir.appendingPathComponent("items.json")
        self.deletedFileURL = dir.appendingPathComponent("deleted.json")
        self.ideasFileURL = dir.appendingPathComponent("ideas.json")

        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        load()
    }

    func load() {
        // Load active items
        if FileManager.default.fileExists(atPath: fileURL.path),
           let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode([PriorityItem].self, from: data) {
            items = decoded
        } else {
            items = Self.sampleItems
            save()
        }

        // Load deleted items
        if FileManager.default.fileExists(atPath: deletedFileURL.path),
           let data = try? Data(contentsOf: deletedFileURL),
           let decoded = try? JSONDecoder().decode([DeletedItem].self, from: data) {
            deletedItems = decoded
        }

        // Load ideas
        if FileManager.default.fileExists(atPath: ideasFileURL.path),
           let data = try? Data(contentsOf: ideasFileURL),
           let decoded = try? JSONDecoder().decode([IdeaItem].self, from: data) {
            ideas = decoded
        }
    }

    func save() {
        if let data = try? JSONEncoder().encode(items) {
            try? data.write(to: fileURL, options: .atomic)
        }
    }

    func saveDeleted() {
        if let data = try? JSONEncoder().encode(deletedItems) {
            try? data.write(to: deletedFileURL, options: .atomic)
        }
    }

    func saveIdeas() {
        if let data = try? JSONEncoder().encode(ideas) {
            try? data.write(to: ideasFileURL, options: .atomic)
        }
    }

    func addIdea(name: String) {
        ideas.append(IdeaItem(name: name))
        saveIdeas()
    }

    func removeIdea(id: UUID) {
        ideas.removeAll { $0.id == id }
        saveIdeas()
    }

    func updateIdea(id: UUID, name: String, notes: String) {
        if let index = ideas.firstIndex(where: { $0.id == id }) {
            ideas[index].name = name
            ideas[index].notes = notes
            saveIdeas()
        }
    }

    // Move an idea into the matrix at a specific fractional position.
    func promoteIdea(id: UUID, x: CGFloat, y: CGFloat, colorName: String = "blue") {
        guard let idea = ideas.first(where: { $0.id == id }) else { return }
        let clampedX = min(max(x, 0.02), 0.98)
        let clampedY = min(max(y, 0.02), 0.98)
        let item = PriorityItem(name: idea.name, x: clampedX, y: clampedY, colorName: colorName, addedDate: Date())
        items.append(item)
        ideas.removeAll { $0.id == id }
        save()
        saveIdeas()
    }

    func addItem(name: String, colorName: String) {
        let jitterX = CGFloat.random(in: -0.05...0.05)
        let jitterY = CGFloat.random(in: -0.05...0.05)
        let item = PriorityItem(name: name, x: 0.25 + jitterX, y: 0.25 + jitterY, colorName: colorName)
        items.append(item)
        save()
    }

    func removeItem(id: UUID) {
        if let item = items.first(where: { $0.id == id }) {
            let deleted = DeletedItem(
                id: item.id,
                name: item.name,
                colorName: item.colorName,
                addedDate: item.addedDate,
                deletedDate: Date()
            )
            deletedItems.insert(deleted, at: 0)
            saveDeleted()
        }
        items.removeAll { $0.id == id }
        save()
    }

    func clearDeletedItems() {
        deletedItems.removeAll()
        saveDeleted()
    }

    func updateItem(id: UUID, name: String, colorName: String) {
        if let index = items.firstIndex(where: { $0.id == id }) {
            items[index].name = name
            items[index].colorName = colorName
            save()
        }
    }

    func resetAddedDate(id: UUID) {
        if let index = items.firstIndex(where: { $0.id == id }) {
            items[index].addedDate = Date()
            save()
        }
    }

    func updatePosition(id: UUID, x: CGFloat, y: CGFloat) {
        if let index = items.firstIndex(where: { $0.id == id }) {
            items[index].x = min(max(x, 0.02), 0.98)
            items[index].y = min(max(y, 0.02), 0.98)
            save()
        }
    }

    static let sampleItems: [PriorityItem] = [
        PriorityItem(name: "Project X", x: 0.15, y: 0.20, colorName: "red"),
        PriorityItem(name: "Fix Server", x: 0.15, y: 0.35, colorName: "orange"),
        PriorityItem(name: "Write Report", x: 0.65, y: 0.20, colorName: "blue"),
        PriorityItem(name: "Plan Event", x: 0.65, y: 0.35, colorName: "purple"),
        PriorityItem(name: "Client Calls", x: 0.15, y: 0.65, colorName: "green"),
        PriorityItem(name: "Data Entry", x: 0.15, y: 0.80, colorName: "green"),
        PriorityItem(name: "Social Media", x: 0.65, y: 0.65, colorName: "yellow"),
        PriorityItem(name: "TV Time", x: 0.65, y: 0.80, colorName: "pink"),
    ]
}
