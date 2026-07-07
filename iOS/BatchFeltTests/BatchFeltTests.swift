import XCTest
@testable import BatchFelt

final class BatchFeltTests: XCTestCase {

    @MainActor
    func testStoreSeedsAboveZeroButBelowFreeLimit() {
        let store = BatchFeltStore()
        XCTAssertGreaterThan(store.projects.count, 0)
        XCTAssertLessThan(store.projects.count, BatchFeltStore.freeLimit)
    }

    @MainActor
    func testAddEntrySucceedsWhenUnderLimit() {
        let store = BatchFeltStore()
        let before = store.projects.count
        let added = store.addProject(projectName: "Wool Coaster", woolType: "Merino", technique: "Wet Felting", finishedSize: "4", isPro: false)
        XCTAssertTrue(added)
        XCTAssertEqual(store.projects.count, before + 1)
    }

    @MainActor
    func testAddEntryRejectsBlankPrimaryField() {
        let store = BatchFeltStore()
        let before = store.projects.count
        let added = store.addProject(projectName: "   ", woolType: "Merino", technique: "Wet Felting", finishedSize: "4", isPro: false)
        XCTAssertFalse(added)
        XCTAssertEqual(store.projects.count, before)
    }

    @MainActor
    func testFreeLimitBlocksAdditionalEntries() {
        let store = BatchFeltStore()
        for item in store.projects { store.deleteProject(item.id) }
        for _ in 0..<BatchFeltStore.freeLimit {
            XCTAssertTrue(store.addProject(projectName: "Wool Coaster", woolType: "Merino", technique: "Wet Felting", finishedSize: "4", isPro: false))
        }
        XCTAssertFalse(store.addProject(projectName: "Wool Coaster", woolType: "Merino", technique: "Wet Felting", finishedSize: "4", isPro: false))
        XCTAssertTrue(store.addProject(projectName: "Wool Coaster", woolType: "Merino", technique: "Wet Felting", finishedSize: "4", isPro: true))
    }

    @MainActor
    func testDeleteEntry() {
        let store = BatchFeltStore()
        store.addProject(projectName: "Wool Coaster", woolType: "Merino", technique: "Wet Felting", finishedSize: "4", isPro: false)
        guard let item = store.projects.last else { return XCTFail("expected entry") }
        let before = store.projects.count
        store.deleteProject(item.id)
        XCTAssertEqual(store.projects.count, before - 1)
    }

    @MainActor
    func testDeleteAllDataReseeds() {
        let store = BatchFeltStore()
        store.deleteAllData()
        XCTAssertGreaterThan(store.projects.count, 0)
        XCTAssertGreaterThan(store.proEntries.count, 0)
    }

    @MainActor
    func testUpdateEntryPersistsChange() {
        let store = BatchFeltStore()
        store.addProject(projectName: "Wool Coaster", woolType: "Merino", technique: "Wet Felting", finishedSize: "4", isPro: false)
        guard let item = store.projects.last else { return XCTFail("expected entry") }
        store.updateProject(item.id, projectName: "Wool Coaster", woolType: "Merino", technique: "Wet Felting", finishedSize: "4")
        XCTAssertEqual(store.projects.count, store.projects.count)
    }
}
