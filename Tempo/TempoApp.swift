//
//  TempoApp.swift
//  Tempo
//
//  Created by Vladyslav on 09/04/2026.
//

import SwiftUI

@main
struct TempoApp: App {
    @StateObject private var store = TimerStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
        .defaultSize(width: 360, height: 500)

        MenuBarExtra {
            MenuBarView()
                .environmentObject(store)
        } label: {
            menuBarLabel
        }
    }

    @ViewBuilder
    private var menuBarLabel: some View {
        if let state = store.activeState {
            Label(state.formattedTimeRemaining, systemImage: "timer")
                .labelStyle(.titleAndIcon)
        } else {
            Image(systemName: "timer")
        }
    }
}
