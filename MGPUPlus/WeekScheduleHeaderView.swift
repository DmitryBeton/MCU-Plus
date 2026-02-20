import SwiftUI

enum Weekday: String, CaseIterable, Identifiable {
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday

    var id: String { rawValue }

    var shortTitle: String {
        switch self {
        case .monday: return "Пн"
        case .tuesday: return "Вт"
        case .wednesday: return "Ср"
        case .thursday: return "Чт"
        case .friday: return "Пт"
        case .saturday: return "Сб"
        case .sunday: return "Вс"
        }
    }
}

struct WeekScheduleHeaderView: View {
    let dateRangeText: String
    let weekLabelText: String
    @Binding var selectedDay: Weekday
    let onPreviousWeek: () -> Void
    let onNextWeek: () -> Void

    var body: some View {
        GeometryReader { geo in
            let contentHeight = max(geo.size.height, 1)
            let verticalSpacing = contentHeight * 0.09
            let horizontalPadding = contentHeight * 0.08
            let arrowSize = contentHeight * 0.10
            let dateFontSize = contentHeight * 0.13
            let weekFontSize = contentHeight * 0.09
            let dayFontSize = contentHeight * 0.08
            let dayButtonHeight = contentHeight * 0.3
            let dayCornerRadius = contentHeight * 0.09

            VStack(spacing: verticalSpacing) {
                HStack {
                    Button(action: onPreviousWeek) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: arrowSize, weight: .light))
                            .foregroundStyle(.mcuRed)
                            .frame(width: arrowSize + 8, height: arrowSize + 8)
                    }
                    .buttonStyle(.plain)

                    Spacer(minLength: 8)

                    Text(dateRangeText)
                        .font(.system(size: dateFontSize, weight: .medium))
                        .minimumScaleFactor(0.4)
                        .lineLimit(1)

                    Spacer(minLength: 8)

                    Button(action: onNextWeek) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: arrowSize, weight: .light))
                            .foregroundStyle(.mcuRed)
                            .frame(width: arrowSize + 8, height: arrowSize + 8)
                    }
                    .buttonStyle(.plain)
                }

                Text(weekLabelText)
                    .font(.system(size: weekFontSize, weight: .regular))
                    .foregroundStyle(.gray)

                HStack(spacing: verticalSpacing * 0.8) {
                    ForEach(Weekday.allCases) { day in
                        Button {
                            selectedDay = day
                        } label: {
                            Text(day.shortTitle)
                                .font(.system(size: dayFontSize, weight: .regular))
                                .foregroundStyle(selectedDay == day ? Color.white : Color.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: dayButtonHeight)
                                .background(selectedDay == day ? Color.mcuRed : Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: dayCornerRadius, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, horizontalPadding)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .clipped()
    }
}

#Preview {
    @Previewable @State var day: Weekday = .tuesday

    WeekScheduleHeaderView(
        dateRangeText: "15 декабря - 21 декабря",
        weekLabelText: "Неделя 16",
        selectedDay: $day,
        onPreviousWeek: {},
        onNextWeek: {}
    )
    .frame(height: 220)
}
