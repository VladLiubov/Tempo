import AppKit
import UserNotifications

/// Manages local notifications for timer completion events.
struct NotificationService {
    /// Set by `TempoFocusFilterIntent` — `false` while a Focus mode that blocks
    /// Tempo notifications is active. Defaults to `true` (notifications allowed).
    static var focusNotificationsAllowed: Bool = true

    /// Requests authorisation to display alerts and play sounds.
    /// Safe to call multiple times — the system ignores repeat requests.
    static func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    /// Plays the completion sound directly and schedules a local notification banner.
    /// The sound plays immediately via `NSSound` so it works even when the app is frontmost.
    /// The notification banner is skipped when the active Focus mode blocks Tempo notifications.
    static func scheduleCompletion(for item: TimerItem) {
        NSSound(named: NSSound.Name(item.soundName))?.play()

        guard focusNotificationsAllowed else { return }

        let content = UNMutableNotificationContent()
        content.title = item.name
        content.body = "Time's up!"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "tempo.complete.\(item.id)",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }
}
