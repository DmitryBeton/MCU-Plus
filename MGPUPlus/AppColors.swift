//
//  AppColors.swift
//  MGPUPlus
//
//  Created by Дмитрий Чалов on 14.02.2026.
//


import SwiftUI

extension Color {
    static let mcuRed = Color("mcuRed")
    static let mcuLightGrey = Color("mcuLightGrey")
    static let mcuGrey = Color("mcuGrey")
    static let appBackground = Color(
        uiColor: UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor(red: 18 / 255, green: 19 / 255, blue: 22 / 255, alpha: 1)
            }

            return .systemBackground
        }
    )
    static let appGroupedBackground = Color(
        uiColor: UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor(red: 22 / 255, green: 24 / 255, blue: 28 / 255, alpha: 1)
            }

            return .systemGroupedBackground
        }
    )
    static let appCardBackground = Color(
        uiColor: UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor(red: 30 / 255, green: 32 / 255, blue: 37 / 255, alpha: 1)
            }

            return .secondarySystemBackground
        }
    )
    static let appPrimaryText = Color(uiColor: .label)
    static let appSecondaryText = Color(uiColor: .secondaryLabel)
    static let appSeparator = Color(uiColor: .separator)
}
