import SwiftUI

struct TimerCardView: View {
    let item: TimerItem
    let activeState: ActiveTimerState?
    let onStart: () -> Void
    let onStop: () -> Void

    private var isActive: Bool { activeState?.item.id == item.id }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(item.name)
                            .font(.headline)
                        if item.focusEnabled {
                            Image(systemName: "moon.fill")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    if isActive, let state = activeState {
                        Text("\(state.formattedTimeRemaining) · \(state.phase == .work ? "Work" : "Break")")
                            .font(.subheadline)
                            .foregroundStyle(.blue)
                    } else {
                        Text(item.type.displayLabel)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                Button(action: isActive ? onStop : onStart) {
                    Label(isActive ? "Stop" : "Start", systemImage: isActive ? "stop.fill" : "play.fill")
                        .font(.subheadline.weight(.semibold))
                }
                .buttonStyle(.borderedProminent)
                .tint(isActive ? .red : .blue)
            }
            if isActive, let state = activeState {
                ProgressView(value: state.progress)
                    .tint(.blue)
            }
        }
        .padding()
        .background(.background.secondary)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
