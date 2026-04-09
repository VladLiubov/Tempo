import SwiftUI

struct TimerFormView: View {
    @Environment(\.dismiss) private var dismiss

    var existingItem: TimerItem? = nil
    let onSave: (TimerItem) -> Void

    @State private var name: String = ""
    @State private var isPomodoro: Bool = false
    @State private var simpleDurationMinutes: Int = 25
    @State private var pomodoroWorkMinutes: Int = 45
    @State private var pomodoroBreakMinutes: Int = 5
    @State private var pomodoroCycles: Int = 4
    @State private var soundName: String = "Glass"

    var body: some View {
        Form {
            Section("Timer") {
                TextField("Name", text: $name)
                Toggle("Pomodoro style", isOn: $isPomodoro)
            }
            if isPomodoro {
                Section("Pomodoro") {
                    Stepper("Work: \(pomodoroWorkMinutes) min", value: $pomodoroWorkMinutes, in: 1...120)
                    Stepper("Break: \(pomodoroBreakMinutes) min", value: $pomodoroBreakMinutes, in: 1...60)
                    Stepper("Cycles: \(pomodoroCycles)", value: $pomodoroCycles, in: 1...12)
                }
            } else {
                Section("Duration") {
                    Stepper("Duration: \(simpleDurationMinutes) min", value: $simpleDurationMinutes, in: 1...240)
                }
            }
        }
        .formStyle(.grouped)
        .frame(minWidth: 320)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { save() }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .navigationTitle(existingItem == nil ? "New Timer" : "Edit Timer")
        .onAppear { populateIfEditing() }
    }

    private func populateIfEditing() {
        guard let item = existingItem else { return }
        name = item.name
        soundName = item.soundName
        switch item.type {
        case .simple(let d):
            isPomodoro = false
            simpleDurationMinutes = Int(d / 60)
        case .pomodoro(let w, let b, let c):
            isPomodoro = true
            pomodoroWorkMinutes = Int(w / 60)
            pomodoroBreakMinutes = Int(b / 60)
            pomodoroCycles = c
        }
    }

    private func save() {
        let type: TimerType = isPomodoro
            ? .pomodoro(
                work: Double(pomodoroWorkMinutes) * 60,
                breakDuration: Double(pomodoroBreakMinutes) * 60,
                cycles: pomodoroCycles
            )
            : .simple(duration: Double(simpleDurationMinutes) * 60)

        var item = existingItem ?? TimerItem(name: name, type: type, focusEnabled: false)
        item.name = name
        item.type = type
        item.soundName = soundName
        onSave(item)
        dismiss()
    }
}
