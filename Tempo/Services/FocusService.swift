import AppKit

/// Controls macOS Focus (Do Not Disturb) mode by running user-created Shortcuts.
///
/// **One-time setup:** Create two Shortcuts in the Shortcuts app:
/// - "Enable DND" — action: Set Focus → Do Not Disturb → On
/// - "Disable DND" — action: Set Focus → Do Not Disturb → Off
struct FocusService {
    /// Runs the "Enable DND" Shortcut to activate Focus mode.
    static func enableFocus() {
        runShortcut(named: "Enable DND")
    }

    /// Runs the "Disable DND" Shortcut to deactivate Focus mode.
    static func disableFocus() {
        runShortcut(named: "Disable DND")
    }

    /// Opens System Settings → Focus for manual Focus management.
    static func openFocusSettings() {
        guard let url = URL(string: "x-apple.systempreferences:com.apple.Focus-Settings.extension") else { return }
        NSWorkspace.shared.open(url)
    }

    private static func runShortcut(named name: String) {
        let encoded = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? name
        guard let url = URL(string: "shortcuts://run-shortcut?name=\(encoded)") else { return }
        NSWorkspace.shared.open(url)
    }
}
