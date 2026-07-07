import Foundation

struct StainProject: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var brand: String = ""
    var color: String = ""
    var topcoat: String = ""
    var dateDone: Date = Date()
}
