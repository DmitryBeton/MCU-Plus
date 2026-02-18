//
//  ContentView.swift
//  MGPUPlus
//
//  Created by Дмитрий Чалов on 11.02.2026.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        TabView {
//            Tab("tab.news", systemImage: "newspaper") {
//                tabScreen(title: "tab.news")
//            }
            Tab("tab.schedule", systemImage: "calendar") {
                ScheduleView()
            }
            Tab("tab.settings", systemImage: "gearshape") {
                tabScreen(title: "tab.settings")
            }
        }
        .tint(.mcuRed)
    }

    private func tabScreen(title: LocalizedStringKey) -> some View {
        ZStack {
            Color.mcuGrey.ignoresSafeArea()
            Text(title)
                .font(.title2)
                .foregroundStyle(.white)
        }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
