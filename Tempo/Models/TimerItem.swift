import Foundation

/// The type of a timer, defining its duration and behaviour.
enum TimerType: Codable, Equatable {
    /// A simple one-shot countdown with the given duration in seconds.
    case simple(duration: TimeInterval)
    /// A Pomodoro-style timer that alternates between work and break phases for a set number of cycles.
    case pomodoro(work: TimeInterval, breakDuration: TimeInterval, cycles: Int)

    /// A human-readable summary of the timer type and duration.
    var displayLabel: String {
        switch self {
        case .simple(let d):
            return "Simple · \(Int(d / 60)) min"
        case .pomodoro(let w, let b, let c):
            return "Pomodoro · \(Int(w / 60))m work / \(Int(b / 60))m break · \(c) cycles"
        }
    }
}

/// A named timer configuration that can be started by the user.
struct TimerItem: Identifiable, Codable, Equatable {
    /// Stable unique identifier.
    let id: UUID
    /// The display name shown in the timer list and notifications.
    var name: String
    /// The timer type (simple countdown or Pomodoro).
    var type: TimerType
    /// When `true`, macOS Focus mode is activated automatically when this timer starts.
    var focusEnabled: Bool
    /// The name of the system sound played when the timer completes.
    var soundName: String

    /// Creates a new `TimerItem`, generating a fresh `UUID` by default.
    init(id: UUID = UUID(), name: String, type: TimerType, focusEnabled: Bool, soundName: String = "Glass") {
        self.id = id
        self.name = name
        self.type = type
        self.focusEnabled = focusEnabled
        self.soundName = soundName
    }
}
