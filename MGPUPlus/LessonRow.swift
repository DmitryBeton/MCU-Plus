//
//  LessonRow.swift
//  MGPUPlus
//
//  Created by Дмитрий Чалов on 15.02.2026.
//

import SwiftUI

struct LessonRow: View {
    let lesson: Lesson

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(.mcuRed)
                .frame(width: 4, height: 80)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 8) {
                Text(lesson.name)
                    .font(.headline)
                    .foregroundStyle(.primary)

                HStack(spacing: 8) {
                    Image(systemName: "alarm")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(lesson.startTime) - \(lesson.endTime)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 8) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.caption)
                        .foregroundStyle(.mcuRed)
                    Text(lesson.room)
                        .font(.subheadline)
                        .foregroundStyle(.mcuRed)
                }

                HStack(spacing: 8) {
                    Image(systemName: "person")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(lesson.teacher)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()
        }
        .padding(14)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 4, y: 1)
        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }
}
