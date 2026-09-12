import Foundation

/// Applies regex-based redaction to string content.
public struct ContentRedactor: Sendable {
    private let patterns: [(label: String, regex: Regex<Substring>)]

    public init(patterns: [(String, Regex<Substring>)] = Self.defaults) {
        self.patterns = patterns.map { ($0.0, $0.1) }
    }

    public static let defaults: [(String, Regex<Substring>)] = [
        ("email", /[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}/),
        ("ssn", /\b\d{3}-\d{2}-\d{4}\b/),
    ]

    public func redact(_ text: String, mask: String = "***") -> String {
        var result = text
        for (_, pattern) in patterns {
            result = result.replacing(pattern, with: mask)
        }
        return result
    }
}
