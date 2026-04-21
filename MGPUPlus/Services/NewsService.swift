import Foundation
import UIKit

struct NewsService {
    private let session: URLSession
    private let baseURL = URL(string: "https://www.mgpu.ru")!
    private let newsURL = URL(string: "https://www.mgpu.ru/news/")!

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchNews() async throws -> [NewsItem] {
        var request = URLRequest(url: newsURL)
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X)", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 30

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw NewsServiceError.invalidResponse
        }

        guard let html = String(data: data, encoding: .utf8) else {
            throw NewsServiceError.invalidHTML
        }

        let news = parseNews(from: html)
        guard !news.isEmpty else {
            throw NewsServiceError.noNewsFound
        }

        return news
    }

    private func parseNews(from html: String) -> [NewsItem] {
        html
            .components(separatedBy: #"<div class="row news">"#)
            .dropFirst()
            .compactMap(parseNewsBlock)
    }

    private func parseNewsBlock(_ block: String) -> NewsItem? {
        let content = block.components(separatedBy: #"<hr class="mt_20 mb_40">"#).first ?? block

        guard
            let articleURLString = firstMatch(in: content, pattern: #"<h2><a href="([^"]+)""#),
            let articleURL = absoluteURL(from: articleURLString),
            let titleHTML = firstMatch(in: content, pattern: #"<h2><a [^>]*>(.*?)</a></h2>"#),
            let summaryHTML = firstMatch(in: content, pattern: #"</div>\s*([^<]+?)\s*<div class="mb_20">"#)
        else {
            return nil
        }

        let imageURL = firstMatch(in: content, pattern: #"<img src="([^"]+)""#).flatMap(absoluteURL(from:))
        let sourceTitle = firstMatch(in: content, pattern: #"<ul class="list-inline posted-info mb_5">[\s\S]*?<li><a [^>]*>(.*?)</a></li>"#)?.decodedHTMLText ?? ""
        let dateText = firstMatch(in: content, pattern: #"<li>(\d{1,2}\s+[^<]+?\s+\d{4}\s+г\.)</li>"#)?.decodedHTMLText ?? ""

        return NewsItem(
            title: titleHTML.decodedHTMLText,
            summary: summaryHTML.decodedHTMLText,
            dateText: dateText,
            sourceTitle: sourceTitle,
            imageURL: imageURL,
            articleURL: articleURL
        )
    }

    private func firstMatch(in text: String, pattern: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive, .dotMatchesLineSeparators]) else {
            return nil
        }

        let range = NSRange(text.startIndex..., in: text)
        guard
            let match = regex.firstMatch(in: text, options: [], range: range),
            match.numberOfRanges > 1,
            let matchRange = Range(match.range(at: 1), in: text)
        else {
            return nil
        }

        return String(text[matchRange])
    }

    private func absoluteURL(from rawValue: String) -> URL? {
        let cleanedValue = rawValue.decodedHTMLText.trimmingCharacters(in: .whitespacesAndNewlines)

        if let url = URL(string: cleanedValue), url.scheme != nil {
            return url
        }

        return URL(string: cleanedValue, relativeTo: baseURL)?.absoluteURL
    }
}

enum NewsServiceError: LocalizedError {
    case invalidResponse
    case invalidHTML
    case noNewsFound

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return NSLocalizedString("news.error.load", comment: "")
        case .invalidHTML:
            return NSLocalizedString("news.error.parse", comment: "")
        case .noNewsFound:
            return NSLocalizedString("news.empty", comment: "")
        }
    }
}

private extension String {
    var decodedHTMLText: String {
        guard let data = data(using: .utf8) else {
            return normalizedWhitespace
        }

        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]

        let attributedText = try? NSAttributedString(data: data, options: options, documentAttributes: nil)
        return (attributedText?.string ?? self).normalizedWhitespace
    }

    var normalizedWhitespace: String {
        replacingOccurrences(of: "\u{00A0}", with: " ")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
