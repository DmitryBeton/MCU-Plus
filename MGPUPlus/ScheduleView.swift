//
//  ScheduleView.swift
//  MGPUPlus
//
//  Created by Дмитрий Чалов on 14.02.2026.
//

import SwiftUI

struct ScheduleView: View {
    let viewModel = ViewModel()
    @State private var selectedDay: Weekday = .tuesday

    var body: some View {
        GeometryReader { geo in
            let safeHeight = geo.size.height - geo.safeAreaInsets.top - geo.safeAreaInsets.bottom
            let headerHeight = max(safeHeight * 0.25, 170)

            VStack(spacing: 0) {
                WeekScheduleHeaderView(
                    dateRangeText: "15 декабря - 21 декабря",
                    weekLabelText: "Неделя 16",
                    selectedDay: $selectedDay,
                    onPreviousWeek: {},
                    onNextWeek: {}
                )
                .frame(height: headerHeight)

                List(viewModel.lessons) { lesson in
                    LessonRow(lesson: lesson)
                }
                .listStyle(.plain)
            }
            .background(.mcuBackground)
        }
    }
}
