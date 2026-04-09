import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject var store: TimerStore

    var body: some View {
        VStack(spacing: 12) {
            if let state = store.activeState {
                VStack(spacing: 6) {
                    Text(state.item.name)
                        .font(.headline)
                    Text(state.phase == .work ? "Work" : "Break")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                HStack(spacing: 12) {
                    Button(state.isPaused ? "Resume" : "Pause") {
                        store.togglePause()
                    }
                    .buttonStyle(.bordered)
                    Button("Stop") {
                        store.stop()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                }
            } else {
                Text("No active timer")
                    .foregroundStyle(.secondary)
                Text("Start a timer from the main window.")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            Divider()

            Button("Focus Settings…") {
                FocusService.openFocusSettings()
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .font(.subheadline)
        }
        .padding()
        .frame(width: 240)
    }
}
