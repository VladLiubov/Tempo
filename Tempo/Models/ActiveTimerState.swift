import Foundation

/// The current phase of a running Pomodoro timer.
enum TimerPhase: Equatable {
    /// The focused work interval.
    case work
    /// The rest interval between work cycles.
    case breakTime
}

/// The in-memory state of a currently running timer.
struct ActiveTimerState: Equatable {
    /// The timer configuration being run.
    let item: TimerItem
    /// Seconds remaining in the current phase.
    var timeRemaining: TimeInterval
    /// Current phase (always `.work` for simple timers).
    var phase: TimerPhase
    /// Number of work cycles completed so far (Pomodoro only).
    var cyclesCompleted: Int
    /// Whether the countdown is paused.
    var isPaused: Bool

    /// Total duration of the current phase in seconds.
    var totalDuration: TimeInterval {
        switch item.type {
        case .simple(let d): return d
        case .pomodoro(let w, let b, _):
            return phase == .work ? w : b
        }
    }

    /// Fraction of the current phase that has elapsed, in `[0, 1]`.
    var progress: Double {
        guard totalDuration > 0 else { return 0 }
        return 1.0 - (max(0, timeRemaining) / totalDuration)
    }

    /// Time remaining formatted as `MM:SS` or `H:MM:SS` for durations over an hour.
    var formattedTimeRemaining: String {
        let total = Int(timeRemaining)
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
