//
//  ViewModel.swift
//  MGPUPlus
//
//  Created by Дмитрий Чалов on 14.02.2026.
//

import Foundation

@Observable
class ViewModel {
    var lessons: [Lesson] = [
        Lesson(id: UUID(),
               pairIndex: 1,
               name: "Архитектура компьютера",
               startTime: "9:00",
               endTime: "10:20",
               room: "205 Б",
               teacher: "Н.Д. Тамошина",
               color: "red"),

        Lesson(id: UUID(),
               pairIndex: 2,
               name: "Математический Анализ",
               startTime: "10:30",
               endTime: "11:50",
               room: "304 А",
               teacher: "Р.А. Ивинкин",
               color: "blue"),
    ]

    
}
