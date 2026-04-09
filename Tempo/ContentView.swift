import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: TimerStore
    @State private var showingNewTimer = false
    @State private var editingItem: TimerItem? = nil

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Tempo")
                    .font(.title2.bold())
                Spacer()
                Button(action: { showingNewTimer = true }) {
                    Label("New", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()

            if store.timers.isEmpty {
                Spacer()
                VStack(spacing: 8) {
                    Image(systemName: "timer")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)
                    Text("No Timers")
                        .font(.headline)
                    Text("Click + to create your first timer.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(store.timers) { item in
                            TimerCardView(
                                item: item,
                                activeState: store.activeState,
                                onStart: { store.start(item) },
                                onStop: { store.stop() }
                            )
                            .contextMenu {
                                Button("Edit") { editingItem = item }
                                Divider()
                                Button("Delete", role: .destructive) {
                                    store.remove(ids: [item.id])
                                }
                            }
                        }
                    }
                    .padding([.horizontal, .bottom])
                }
            }
        }
        .frame(minWidth: 320, minHeight: 400)
        .sheet(isPresented: $showingNewTimer) {
            NavigationStack {
                TimerFormView { store.add($0) }
            }
        }
        .sheet(item: $editingItem) { item in
            NavigationStack {
                TimerFormView(existingItem: item) { store.update($0) }
            }
        }
    }
}
