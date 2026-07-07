import Foundation

@MainActor
final class BatchFeltStore: ObservableObject {
    @Published private(set) var projects: [Project] = []
    @Published private(set) var proEntries: [BFProEntry] = []

    static let freeLimit = 30

    private let fileURL: URL
    private let proFileURL: URL

    init() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        self.fileURL = dir.appendingPathComponent("batchfelt_projects.json")
        self.proFileURL = dir.appendingPathComponent("batchfelt_pro.json")
        if ProcessInfo.processInfo.arguments.contains("-uiTestReset") {
            try? FileManager.default.removeItem(at: fileURL)
            try? FileManager.default.removeItem(at: proFileURL)
        }
        load()
        if projects.isEmpty {
            seedDefaults()
        }
        if proEntries.isEmpty {
            seedProDefaults()
        }
    }

    private func seedDefaults() {
        projects = [
            Project(projectName: "Wool Coaster", woolType: "Merino", technique: "Wet Felting", finishedSize: "4"),
            Project(projectName: "Felted Bird", woolType: "Corriedale", technique: "Needle Felting", finishedSize: "3")
        ]
        save()
    }

    private func seedProDefaults() {
        proEntries = [
            BFProEntry(woolType: "Merino", technique: "Wet Felting", startSize: "6", shrinkPercent: "25"),
            BFProEntry(woolType: "Corriedale", technique: "Needle Felting", startSize: "4", shrinkPercent: "10")
        ]
        saveProEntries()
    }

    func canAdd(isPro: Bool) -> Bool {
        isPro || projects.count < Self.freeLimit
    }

    @discardableResult
    func addProject(projectName: String, woolType: String, technique: String, finishedSize: String, isPro: Bool) -> Bool {
        let trimmed = projectName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, canAdd(isPro: isPro) else { return false }
        let item = Project(projectName: projectName, woolType: woolType, technique: technique, finishedSize: finishedSize)
        projects.append(item)
        save()
        return true
    }

    func updateProject(_ id: UUID, projectName: String, woolType: String, technique: String, finishedSize: String) {
        guard let idx = projects.firstIndex(where: { $0.id == id }) else { return }
        projects[idx].projectName = projectName
        projects[idx].woolType = woolType
        projects[idx].technique = technique
        projects[idx].finishedSize = finishedSize
        save()
    }

    func deleteProject(_ id: UUID) {
        projects.removeAll { $0.id == id }
        save()
    }

    func deleteAllData() {
        projects = []
        proEntries = []
        seedDefaults()
        seedProDefaults()
    }

    // MARK: - Pro entries

    @discardableResult
    func addProEntry(woolType: String, technique: String, startSize: String, shrinkPercent: String) -> Bool {
        let entry = BFProEntry(woolType: woolType, technique: technique, startSize: startSize, shrinkPercent: shrinkPercent)
        proEntries.append(entry)
        saveProEntries()
        return true
    }

    func deleteProEntry(_ id: UUID) {
        proEntries.removeAll { $0.id == id }
        saveProEntries()
    }

    // MARK: - Persistence

    private struct Snapshot: Codable {
        var items: [Project]
    }
    private struct ProSnapshot: Codable {
        var items: [BFProEntry]
    }

    private func load() {
        if let data = try? Data(contentsOf: fileURL), let decoded = try? JSONDecoder().decode(Snapshot.self, from: data) {
            projects = decoded.items
        }
        if let data = try? Data(contentsOf: proFileURL), let decoded = try? JSONDecoder().decode(ProSnapshot.self, from: data) {
            proEntries = decoded.items
        }
    }

    private func save() {
        let snapshot = Snapshot(items: projects)
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    private func saveProEntries() {
        let snapshot = ProSnapshot(items: proEntries)
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        try? data.write(to: proFileURL, options: .atomic)
    }
}
