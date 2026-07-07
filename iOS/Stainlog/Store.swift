import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published var items: [StainProject] = []
    @Published var isPro: Bool = false

    /// Free-tier cap. Deliberately kept above the seed count so a fresh
    /// install never trips the paywall on first launch.
    static let freeLimit = 8

    private let fileURL: URL

    init() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Stainlog", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("items.json")
        load()
    }

    func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([StainProject].self, from: data) else {
            items = [
        StainProject(brand: "Sample Brand 1", color: "Sample Color 1", topcoat: "Sample Topcoat 1", dateDone: Date().addingTimeInterval(-604800)),
        StainProject(brand: "Sample Brand 2", color: "Sample Color 2", topcoat: "Sample Topcoat 2", dateDone: Date().addingTimeInterval(-1209600)),
        StainProject(brand: "Sample Brand 3", color: "Sample Color 3", topcoat: "Sample Topcoat 3", dateDone: Date().addingTimeInterval(-1814400))
            ]
            save()
            return
        }
        items = decoded
    }

    func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    var canAddMore: Bool {
        isPro || items.count < Store.freeLimit
    }

    @discardableResult
    func add(_ item: StainProject) -> Bool {
        guard canAddMore else { return false }
        items.insert(item, at: 0)
        save()
        return true
    }

    func update(_ item: StainProject) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx] = item
        save()
    }

    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        save()
    }

    func delete(_ item: StainProject) {
        items.removeAll { $0.id == item.id }
        save()
    }
}
