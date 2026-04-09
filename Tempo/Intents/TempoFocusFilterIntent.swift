import AppIntents

/// Registers Tempo with the macOS Focus system using `SetFocusFilterIntent`.
///
/// Once this is in place, Tempo appears in **System Settings → Focus → [mode] → App Filters**.
/// The user can configure per-Focus-mode whether Tempo delivers timer notifications.
/// The system calls `perform()` when entering or leaving a Focus mode that has Tempo configured.
struct TempoFocusFilterIntent: SetFocusFilterIntent {

    static var title: LocalizedStringResource = "Tempo"

    /// Display name shown in Focus settings and Siri.
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "Tempo")
    }

    /// When `true`, Tempo delivers timer completion notifications during this Focus mode.
    @Parameter(title: "Allow Timer Notifications", default: true)
    var allowNotifications: Bool

    func perform() async throws -> some IntentResult {
        await MainActor.run {
            NotificationService.focusNotificationsAllowed = allowNotifications
        }
        return .result()
    }
}
