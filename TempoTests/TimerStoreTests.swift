import XCTest
@testable import Tempo

@MainActor
final class TimerStoreTests: XCTestCase {
    var store: TimerStore!
    var storeURL: URL!

    override func setUp() {
        super.setUp()
        storeURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString + ".json")
        store = TimerStore(saveURL: storeURL)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: storeURL)
        store = nil
        storeURL = nil
        super.tearDown()
    }

    func testAddTimer() {
        let item = TimerItem(name: "Work", type: .simple(duration: 1500), focusEnabled: false)
        store.add(item)
        XCTAssertEqual(store.timers.count, 1)
        XCTAssertEqual(store.timers[0].name, "Work")
    }

    func testRemoveTimer() {
        let item = TimerItem(name: "Work", type: .simple(duration: 1500), focusEnabled: false)
        store.add(item)
        store.remove(ids: [item.id])
        XCTAssertEqual(store.timers.count, 0)
    }

    func testUpdateTimer() {
        var item = TimerItem(name: "Work", type: .simple(duration: 1500), focusEnabled: false)
        store.add(item)
        item.name = "Deep Work"
        store.update(item)
        XCTAssertEqual(store.timers[0].name, "Deep Work")
    }

    func testPersistence() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString + ".json")
        defer { try? FileManager.default.removeItem(at: url) }
        let store1 = TimerStore(saveURL: url)
        store1.add(TimerItem(name: "Reading", type: .simple(duration: 1800), focusEnabled: false))
        let store2 = TimerStore(saveURL: url)
        XCTAssertEqual(store2.timers.count, 1)
        XCTAssertEqual(store2.timers[0].name, "Reading")
    }

    func testStartTimerSetsActiveState() {
        let item = TimerItem(name: "Work", type: .simple(duration: 1500), focusEnabled: false)
        store.add(item)
        store.start(item)
        XCTAssertNotNil(store.activeState)
        XCTAssertEqual(store.activeState?.item.id, item.id)
        XCTAssertEqual(store.activeState?.timeRemaining, 1500)
        XCTAssertEqual(store.activeState?.phase, .work)
        store.stop()
    }

    func testStopClearsActiveState() {
        let item = TimerItem(name: "Work", type: .simple(duration: 1500), focusEnabled: false)
        store.add(item)
        store.start(item)
        store.stop()
        XCTAssertNil(store.activeState)
    }

    func testTogglePause() {
        let item = TimerItem(name: "Work", type: .simple(duration: 1500), focusEnabled: false)
        store.add(item)
        store.start(item)
        XCTAssertEqual(store.activeState?.isPaused, false)
        store.togglePause()
        XCTAssertEqual(store.activeState?.isPaused, true)
        store.togglePause()
        XCTAssertEqual(store.activeState?.isPaused, false)
        store.stop()
    }

    func testStartingNewTimerStopsCurrent() {
        let item1 = TimerItem(name: "Work", type: .simple(duration: 1500), focusEnabled: false)
        let item2 = TimerItem(name: "Break", type: .simple(duration: 300), focusEnabled: false)
        store.add(item1)
        store.add(item2)
        store.start(item1)
        store.start(item2)
        XCTAssertEqual(store.activeState?.item.id, item2.id)
        store.stop()
    }

    func testPomodoroStartsInWorkPhase() {
        let item = TimerItem(
            name: "Pomodoro",
            type: .pomodoro(work: 1500, breakDuration: 300, cycles: 4),
            focusEnabled: false
        )
        store.add(item)
        store.start(item)
        XCTAssertEqual(store.activeState?.phase, .work)
        XCTAssertEqual(store.activeState?.timeRemaining, 1500)
        store.stop()
    }
}
