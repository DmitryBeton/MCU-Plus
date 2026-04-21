import Foundation

struct NewsItem: Identifiable, Hashable {
    let title: String
    let summary: String
    let dateText: String
    let sourceTitle: String
    let imageURL: URL?
    let articleURL: URL

    var id: String {
        articleURL.absoluteString
    }
}
