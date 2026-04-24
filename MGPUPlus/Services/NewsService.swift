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
        try await fetchNews(page: 1)
    }

    func fetchNews(page: Int) async throws -> [NewsItem] {
        debugLog("Start loading news page \(page)")

        var components = URLComponents(url: newsURL, resolvingAgainstBaseURL: false)
        if page > 1 {
            components?.queryItems = [
                URLQueryItem(name: "sf_paged", value: "\(page)")
            ]
        }

        guard let pageURL = components?.url else {
            debugLog("Failed to build page URL for page \(page)")
            throw NewsServiceError.invalidResponse
        }

        debugLog("Request URL: \(pageURL.absoluteString)")

        var request = URLRequest(url: pageURL)
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X)", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 30

        let html = try await fetchHTML(for: request)
        let news = parseNews(from: html)
        debugLog("Parsed \(news.count) news items on page \(page)")

        if page == 1, news.isEmpty {
            debugLog("No news found on the first page")
            throw NewsServiceError.noNewsFound
        }

        return news
    }

    func fetchNewsDetail(for item: NewsItem) async throws -> NewsArticleDetail {
        debugLog("Start loading article detail: \(item.articleURL.absoluteString)")

        var request = URLRequest(url: item.articleURL)
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X)", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 30

        let html = try await fetchHTML(for: request)
        guard let detail = parseNewsDetail(from: html, fallbackItem: item) else {
            debugLog("Failed to parse article detail for \(item.articleURL.absoluteString)")
            throw NewsServiceError.invalidHTML
        }

        debugLog("Parsed article detail: \(detail.title)")
        return detail
    }

    private func fetchHTML(for request: URLRequest) async throws -> String {
        do {
            let (data, response) = try await session.data(for: request)

            if let httpResponse = response as? HTTPURLResponse {
                debugLog("HTTP status \(httpResponse.statusCode) for \(request.url?.absoluteString ?? "unknown URL")")
            } else {
                debugLog("Non-HTTP response for \(request.url?.absoluteString ?? "unknown URL")")
            }

            guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                throw NewsServiceError.invalidResponse
            }

            debugLog("Received \(data.count) bytes")

            guard let html = String(data: data, encoding: .utf8) else {
                debugLog("Failed to decode HTML as UTF-8")
                throw NewsServiceError.invalidHTML
            }

            return html
        } catch {
            debugLog("Network request failed: \(error.localizedDescription)")
            throw error
        }
    }

    private func parseNews(from html: String) -> [NewsItem] {
        let desktopItems = html
            .components(separatedBy: #"<div class="row news">"#)
            .dropFirst()
            .compactMap(parseNewsBlock)

        if !desktopItems.isEmpty {
            debugLog("HTML desktop news block count after parsing: \(desktopItems.count)")
            return desktopItems
        }

        let mobileItems = html
            .components(separatedBy: #"<div class="news_block">"#)
            .dropFirst()
            .compactMap(parseMobileNewsBlock)

        debugLog("HTML mobile news block count after parsing: \(mobileItems.count)")
        return mobileItems
    }

    private func parseNewsBlock(_ block: String) -> NewsItem? {
        let content = block.components(separatedBy: #"<hr class="mt_20 mb_40">"#).first ?? block

        guard
            let articleURLString = firstMatch(in: content, pattern: #"<h2><a href="([^"]+)""#),
            let articleURL = absoluteURL(from: articleURLString),
            let titleHTML = firstMatch(in: content, pattern: #"<h2><a [^>]*>(.*?)</a></h2>"#),
            let summaryHTML = firstMatch(in: content, pattern: #"</div>\s*([^<]+?)\s*<div class="mb_20">"#)
        else {
            debugLog("Skipped one news block because required fields were not found")
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

    private func parseMobileNewsBlock(_ block: String) -> NewsItem? {
        let content = block.components(separatedBy: #"<div class="mb_30"></div>"#).first ?? block

        guard
            let articleURLString = firstMatch(in: content, pattern: #"<a href="([^"]+)">"#),
            let articleURL = absoluteURL(from: articleURLString),
            let titleHTML = firstMatch(in: content, pattern: #"<h3><a [^>]*>(.*?)</a></h3>"#),
            let summaryHTML = firstMatch(in: content, pattern: #"</h3>\s*(.*?)\s*<hr class="mt_10 mb_10">"#)
        else {
            debugLog("Skipped one mobile news block because required fields were not found")
            return nil
        }

        let imageURL = firstMatch(in: content, pattern: #"<img [^>]*src="([^"]+)""#).flatMap(absoluteURL(from:))
        let dateText = firstMatch(in: content, pattern: #"<ul class="list-inline posted-info">[\s\S]*?<li>(\d{1,2}\s+[^<]+?\s+\d{4}\s+г\.)</li>"#)?.decodedHTMLText ?? ""
        let sourceTitle = firstMatch(in: content, pattern: #"<div class="news_block_badge"[\s\S]*?<a [^>]*>\s*(.*?)\s*</a>"#)?.decodedHTMLText ?? ""

        return NewsItem(
            title: titleHTML.decodedHTMLText,
            summary: summaryHTML.decodedHTMLText,
            dateText: dateText,
            sourceTitle: sourceTitle,
            imageURL: imageURL,
            articleURL: articleURL
        )
    }

    private func parseNewsDetail(from html: String, fallbackItem: NewsItem) -> NewsArticleDetail? {
        let title = firstMatch(in: html, pattern: #"<h2 class="entry-title">(.*?)</h2>"#)?.decodedHTMLText ?? fallbackItem.title
        let sourceTitle = firstMatch(in: html, pattern: #"<ul class="list-inline posted-info mb_5">[\s\S]*?<li><a [^>]*>(.*?)</a></li>"#)?.decodedHTMLText ?? fallbackItem.sourceTitle
        let dateText = firstMatch(in: html, pattern: #"<ul class="list-inline posted-info mb_5">[\s\S]*?<li>(\d{1,2}\s+[^<]+?\s+\d{4}\s+г\.)</li>"#)?.decodedHTMLText ?? fallbackItem.dateText
        let imageURL = firstMatch(in: html, pattern: #"</div><!-- \.entry-meta -->[\s\S]*?<img src="([^"]+)""#)
            .flatMap(absoluteURL(from:)) ?? fallbackItem.imageURL

        guard let contentHTML = firstMatch(in: html, pattern: #"<div class="entry-content">(.*?)</div><!-- \.entry-content -->"#) else {
            debugLog("Entry content block not found in article HTML")
            return nil
        }

        let bodyText = contentHTML.newsBodyText
        guard !bodyText.isEmpty else {
            debugLog("Article body text is empty after HTML cleanup")
            return nil
        }

        return NewsArticleDetail(
            title: title,
            sourceTitle: sourceTitle,
            dateText: dateText,
            imageURL: imageURL,
            bodyText: bodyText,
            articleURL: fallbackItem.articleURL
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

    private func debugLog(_ message: String) {
#if DEBUG
        print("[NewsService] \(message)")
#endif
    }
}

enum NewsServiceError: LocalizedError {
    case invalidResponse
    case invalidHTML
    case noNewsFound
    case noArticleContent

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return NSLocalizedString("news.error.load", comment: "")
        case .invalidHTML:
            return NSLocalizedString("news.error.parse", comment: "")
        case .noNewsFound:
            return NSLocalizedString("news.empty", comment: "")
        case .noArticleContent:
            return NSLocalizedString("news.detail.empty", comment: "")
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

    var newsBodyText: String {
        var html = self
        let replacements = [
            (#"<br\s*/?>"#, "\n"),
            (#"</p>"#, "\n\n"),
            (#"</div>"#, "\n"),
            (#"<div class="su-image-carousel[\s\S]*?</script>"#, ""),
            (#"<script[\s\S]*?</script>"#, ""),
            (#"<style[\s\S]*?</style>"#, "")
        ]

        for (pattern, value) in replacements {
            html = html.replacingOccurrences(of: pattern, with: value, options: .regularExpression)
        }

        return html.decodedHTMLText
            .replacingOccurrences(of: "\n{3,}", with: "\n\n", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
