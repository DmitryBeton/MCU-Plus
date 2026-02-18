//
//  ScheduleView.swift
//  MGPUPlus
//
//  Created by Дмитрий Чалов on 14.02.2026.
//

import SwiftUI

struct ScheduleView: View {
    let viewModel = ViewModel()

    var body: some View {
        

        List(viewModel.lessons) { lesson in
            LessonRow(lesson: lesson)
        }
        .listStyle(.plain)
    }
}
