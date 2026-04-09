import Foundation
import Combine
import os

/// Central store for the timer list and the currently running timer.
///
/// `TimerStore` owns the list of ``TimerItem`` values, persists them to disk,
/// and drives the countdown engine via a Combine `Timer` publisher.
/// Inject it as an `@EnvironmentObject` into SwiftUI scenes.
@MainActor
class TimerStore: ObservableObject {
    /// The ordered list of saved timers.
    @Published var timers: [TimerItem] = []
    /// State of the currently running timer, or `nil` when idle.
    @Published var activeState: ActiveTimerState?

    /// File URL used to persist the timer list as JSON.
    private let saveURL: URL
    /// Subscription that fires the one-second countdown tick.
    private var tickCancellable: AnyCancellable?

    /// Convenience initialiser that stores data in the app's Application Support directory.
    convenience init() {
        let appSupport = FileManager.default.urls(
            for: .applicationSupportDirectory, in: .userDomainMask
        ).first!
        let dir = appSupport.appendingPathComponent("Tempo")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        self.init(saveURL: dir.appendingPathComponent("timers.json"))
    }

    /// Designated initialiser. Loads persisted timers from `saveURL`, requests notification
    /// permission, and wires up the default `onTimerComplete` handler.
    init(saveURL: URL) {
        self.saveURL = saveURL
        load()
        NotificationService.requestPermission()
        onTimerComplete = { item in
            NotificationService.scheduleCompletion(for: item)
        }
    }

    // nonisolated deinit required to avoid Swift runtime crash when
    // @MainActor class is deallocated from a non-main thread in XCTest (Xcode 26 beta).
    nonisolated deinit {}

    /// Appends a new timer to the list and persists the updated list.
    func add(_ item: TimerItem) {
        timers.append(item)
        save()
    }

    /// Removes all timers whose IDs are in `ids` and persists the updated list.
    func remove(ids: Set<UUID>) {
        timers.removeAll { ids.contains($0.id) }
        save()
    }

    /// Replaces the existing timer that has the same `id` as `item` and persists the change.
    func update(_ item: TimerItem) {
        guard let index = timers.firstIndex(where: { $0.id == item.id }) else { return }
        timers[index] = item
        save()
    }

    /// Called when a timer (or its final Pomodoro cycle) reaches zero.
    /// Set this to fire notifications and deactivate Focus mode.
    var onTimerComplete: ((TimerItem) -> Void)?

    /// Starts a new countdown for `item`, cancelling any in-progress timer.
    /// Activates Focus mode when `item.focusEnabled` is `true`.
    func start(_ item: TimerItem) {
        tickCancellable?.cancel()
        let initialDuration: TimeInterval
        switch item.type {
        case .simple(let d): initialDuration = d
        case .pomodoro(let w, _, _): initialDuration = w
        }
        activeState = ActiveTimerState(
            item: item,
            timeRemaining: initialDuration,
            phase: .work,
            cyclesCompleted: 0,
            isPaused: false
        )
        startTicking()
    }

    /// Cancels the running timer and clears `activeState`.
    func stop() {
        tickCancellable?.cancel()
        tickCancellable = nil
        activeState = nil
    }

    /// Toggles between paused and running states.
    /// Resumes the Combine tick publisher when unpausing.
    func togglePause() {
        guard activeState != nil else { return }
        activeState?.isPaused.toggle()
        if activeState?.isPaused == false {
            startTicking()
        } else {
            tickCancellable?.cancel()
        }
    }

    /// Subscribes to a one-second Combine timer and routes each firing to `tick()`.
    private func startTicking() {
        tickCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    /// Decrements `timeRemaining` by one second and triggers phase-end handling when it reaches zero.
    private func tick() {
        guard var state = activeState, !state.isPaused else { return }
        state.timeRemaining -= 1
        if state.timeRemaining <= 0 {
            handlePhaseEnd(state: state)
        } else {
            activeState = state
        }
    }

    /// Handles the end of a phase: completes the timer for simple types, or transitions
    /// between work and break phases (and between cycles) for Pomodoro timers.
    private func handlePhaseEnd(state: ActiveTimerState) {
        tickCancellable?.cancel()
        switch state.item.type {
        case .simple:
            activeState = nil
            onTimerComplete?(state.item)
        case .pomodoro(let w, let b, let totalCycles):
            if state.phase == .work {
                let newCycles = state.cyclesCompleted + 1
                if newCycles >= totalCycles {
                    activeState = nil
                    onTimerComplete?(state.item)
                } else {
                    activeState = ActiveTimerState(
                        item: state.item,
                        timeRemaining: b,
                        phase: .breakTime,
                        cyclesCompleted: newCycles,
                        isPaused: false
                    )
                    startTicking()
                }
            } else {
                activeState = ActiveTimerState(
                    item: state.item,
                    timeRemaining: w,
                    phase: .work,
                    cyclesCompleted: state.cyclesCompleted,
                    isPaused: false
                )
                startTicking()
            }
        }
    }

    /// Encodes the current timer list to JSON and writes it to `saveURL`.
    private func save() {
        do {
            let data = try JSONEncoder().encode(timers)
            try data.write(to: saveURL)
        } catch {
            Logger().error("TimerStore: failed to save timers: \(error)")
        }
    }

    /// Loads the timer list from `saveURL`, silently ignoring missing or malformed files.
    private func load() {
        guard let data = try? Data(contentsOf: saveURL),
              let items = try? JSONDecoder().decode([TimerItem].self, from: data) else { return }
        timers = items
    }
}
