import SwiftUI

struct NewsView: View {
    private let mockNews: [NewsItem] = [
        NewsItem(
            title: "МГПУ запускает весеннюю школу цифровых практик",
            summary: "Студенты смогут принять участие в интенсиве по современным образовательным технологиям и разработке интерактивных учебных материалов.",
            imageURL: URL(string: "https://picsum.photos/seed/mgpu-news-1/800/500")
        ),
        NewsItem(
            title: "В университете пройдет серия открытых лекций для абитуриентов",
            summary: "Преподаватели института расскажут о направлениях подготовки, учебных проектах и возможностях студенческой жизни в новом семестре.",
            imageURL: URL(string: "https://picsum.photos/seed/mgpu-news-2/800/500")
        ),
        NewsItem(
            title: "Команда волонтеров представила обновленную инициативу для кампуса",
            summary: "В проект вошли новые студенческие сервисы, поддержка навигации по корпусам и единая лента университетских новостей.",
            imageURL: URL(string: "https://picsum.photos/seed/mgpu-news-3/800/500")
        )
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(mockNews) { item in
                        NewsCardView(item: item)
                    }
                }
                .padding(16)
            }
            .scrollIndicators(.hidden)
            .background(Color.appDarkGroupedBackground)
            .navigationTitle("tab.news")
        }
        .background(Color.appDarkGroupedBackground)
    }
}

private struct NewsCardView: View {
    let item: NewsItem

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            AsyncImage(url: item.imageURL) { phase in
                switch phase {
                case .empty:
                    placeholder
                case let .success(image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    placeholder
                @unknown default:
                    placeholder
                }
            }
            .frame(height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 18))

            VStack(alignment: .leading, spacing: 8) {
                Text(item.title)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Color(uiColor: .label))

                Text(item.summary)
                    .font(.subheadline)
                    .foregroundStyle(Color(uiColor: .secondaryLabel))
                    .lineLimit(3)
            }
        }
        .padding(14)
        .background(Color.appDarkCardBackground, in: RoundedRectangle(cornerRadius: 22))
    }

    private var placeholder: some View {
        LinearGradient(
            colors: [.mcuRed.opacity(0.9), .mcuGrey.opacity(0.55), .mcuLightGrey.opacity(0.75)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay {
            Image(systemName: "photo")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(.white.opacity(0.85))
        }
    }
}

private struct NewsItem: Identifiable {
    let id = UUID()
    let title: String
    let summary: String
    let imageURL: URL?
}

#Preview {
    NewsView()
}
