//
//  Lesson.swift
//  MGPUPlus
//
//  Created by Дмитрий Чалов on 14.02.2026.
//

import Foundation

struct Lesson: Codable, Identifiable {
    let id: UUID
    let pairIndex: Int
    let name: String
    let startTime: String
    let endTime: String
    let room: String
    let teacher: String
    let color: String
}
