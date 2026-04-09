import XCTest
@testable import Tempo

final class TimerItemTests: XCTestCase {

    func testTimerTypeSimpleLabel() {
        let type = TimerType.simple(duration: 25 * 60)
        XCTAssertEqual(type.displayLabel, "Simple · 25 min")
    }

    func testTimerTypePomodoroLabel() {
        let type = TimerType.pomodoro(work: 45 * 60, breakDuration: 5 * 60, cycles: 4)
        XCTAssertEqual(type.displayLabel, "Pomodoro · 45m work / 5m break · 4 cycles")
    }

    func testTimerItemCodable() throws {
        let item = TimerItem(name: "Deep Work", type: .simple(duration: 1500), focusEnabled: true)
        let data = try JSONEncoder().encode(item)
        let decoded = try JSONDecoder().decode(TimerItem.self, from: data)
        XCTAssertEqual(item, decoded)
    }

    func testActiveTimerProgress() {
        let item = TimerItem(name: "Work", type: .simple(duration: 100), focusEnabled: false)
        let state = ActiveTimerState(item: item, timeRemaining: 75, phase: .work, cyclesCompleted: 0, isPaused: false)
        XCTAssertEqual(state.progress, 0.25, accuracy: 0.001)
    }

    func testFormattedTimeRemaining() {
        let item = TimerItem(name: "Work", type: .simple(duration: 3600), focusEnabled: false)
        let state = ActiveTimerState(item: item, timeRemaining: 125, phase: .work, cyclesCompleted: 0, isPaused: false)
        XCTAssertEqual(state.formattedTimeRemaining, "02:05")
    }

    func testFormattedTimeRemainingWithHours() {
        let item = TimerItem(name: "Work", type: .simple(duration: 7200), focusEnabled: false)
        let state = ActiveTimerState(item: item, timeRemaining: 3661, phase: .work, cyclesCompleted: 0, isPaused: false)
        XCTAssertEqual(state.formattedTimeRemaining, "1:01:01")
    }
}
