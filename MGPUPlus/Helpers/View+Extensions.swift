//
//  View+Extensions.swift
//  MGPUPlus
//
//  Created by Дмитрий Чалов on 27.02.2026.
//

import SwiftUI

extension Color {
    static var appDarkBackground: Color {
        Color(
            uiColor: UIColor { traitCollection in
                if traitCollection.userInterfaceStyle == .dark {
                    return UIColor(red: 18 / 255, green: 19 / 255, blue: 22 / 255, alpha: 1)
                }

                return .systemBackground
            }
        )
    }

    static var appDarkGroupedBackground: Color {
        Color(
            uiColor: UIColor { traitCollection in
                if traitCollection.userInterfaceStyle == .dark {
                    return UIColor(red: 22 / 255, green: 24 / 255, blue: 28 / 255, alpha: 1)
                }

                return .systemGroupedBackground
            }
        )
    }

    static var appDarkCardBackground: Color {
        Color(
            uiColor: UIColor { traitCollection in
                if traitCollection.userInterfaceStyle == .dark {
                    return UIColor(red: 30 / 255, green: 32 / 255, blue: 37 / 255, alpha: 1)
                }

                return .secondarySystemBackground
            }
        )
    }
}

// Custom View Extension
extension View {
    /// Custom Spacers
    @ViewBuilder
    func hSpacing(_ alignment: Alignment) -> some View {
        self
            .frame(maxWidth: .infinity, alignment: alignment)
    }

    @ViewBuilder
    func vSpacing(_ alignment: Alignment) -> some View {
        self
            .frame(maxHeight: .infinity, alignment: alignment)
    }

    // Checking Two dates are same
    func isSameDate(_ date1: Date, _ date2: Date) -> Bool {
        return Calendar.current.isDate(date1, inSameDayAs: date2)
    }
}
