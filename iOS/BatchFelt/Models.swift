import Foundation

struct Project: Identifiable, Codable, Equatable {
    let id: UUID
    var projectName: String
    var woolType: String
    var technique: String
    var finishedSize: String
    var createdDate: Date

    init(id: UUID = UUID(), projectName: String = "Wool Coaster", woolType: String = "Merino", technique: String = "Wet Felting", finishedSize: String = "4", createdDate: Date = Date()) {
        self.id = id
        self.projectName = projectName
        self.woolType = woolType
        self.technique = technique
        self.finishedSize = finishedSize
        self.createdDate = createdDate
    }
}

/// Pro bonus feature entry: Shrinkage-Rate Calculator.
struct BFProEntry: Identifiable, Codable, Equatable {
    let id: UUID
    var woolType: String
    var technique: String
    var startSize: String
    var shrinkPercent: String
    var createdDate: Date

    init(id: UUID = UUID(), woolType: String = "Merino", technique: String = "Wet Felting", startSize: String = "6", shrinkPercent: String = "25", createdDate: Date = Date()) {
        self.id = id
        self.woolType = woolType
        self.technique = technique
        self.startSize = startSize
        self.shrinkPercent = shrinkPercent
        self.createdDate = createdDate
    }
}

enum BFWoolTypeOption {
    static let all = ["Merino", "Corriedale", "Romney", "Blend"]
}

enum BFTechniqueOption {
    static let all = ["Needle Felting", "Wet Felting", "Nuno Felting"]
}
