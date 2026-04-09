import AppKit

/// Opens the macOS Focus settings page in System Settings.
struct FocusService {
    /// Opens System Settings → Focus so the user can manage Focus modes directly.
    static func openFocusSettings() {
        guard let url = URL(string: "x-apple.systempreferences:com.apple.Focus-Settings.extension") else { return }
        NSWorkspace.shared.open(url)
    }
}
