import Foundation
import Logging

/// A structured log sanitizer that recursively masks sensitive fields.
public struct LogSanitizer: Sendable {
    public let sensitiveKeys: Set<String>
    public let maskChar: Character
    private let normalizedKeys: Set<String>

    public static let defaultSensitiveKeys: Set<String> = [
        "password", "token", "secret", "authorization",
        "apikey", "api_key", "accesstoken", "access_token",
        "ssn", "creditcard", "credit_card", "cvv"
    ]

    public init(sensitiveKeys: Set<String> = defaultSensitiveKeys, maskChar: Character = "*") {
        self.sensitiveKeys = sensitiveKeys
        self.maskChar = maskChar
        self.normalizedKeys = Set(sensitiveKeys.map { $0.lowercased() })
    }

    public func sanitize(_ dictionary: [String: Any]) -> [String: Any] {
        var result = [String: Any]()
        for (key, value) in dictionary {
            if isSensitive(key: key) {
                result[key] = mask(value: value)
            } else if let nestedDict = value as? [String: Any] {
                result[key] = sanitize(nestedDict)
            } else if let nestedArray = value as? [Any] {
                result[key] = sanitizeArray(nestedArray)
            } else {
                result[key] = value
            }
        }
        return result
    }

    public func sanitize(_ metadata: Logger.Metadata) -> Logger.Metadata {
        var result: Logger.Metadata = [:]
        for (key, value) in metadata {
            if isSensitive(key: key) {
                result[key] = maskMetadata(value: value)
            } else {
                switch value {
                case .dictionary(let dict):
                    result[key] = .dictionary(sanitize(dict))
                case .array(let array):
                    result[key] = .array(array.map { sanitizeMetadataValue($0) })
                default:
                    result[key] = value
                }
            }
        }
        return result
    }

    private func isSensitive(key: String) -> Bool {
        sensitiveKeys.contains(key) || normalizedKeys.contains(key.lowercased())
    }

    private func mask(value: Any) -> Any {
        if let dict = value as? [String: Any] {
            return dict.mapValues { mask(value: $0) }
        } else if let array = value as? [Any] {
            return array.map { mask(value: $0) }
        }
        let length = max(String(describing: value).count, 1)
        return String(repeating: maskChar, count: length)
    }

    private func sanitizeArray(_ array: [Any]) -> [Any] {
        array.map { element in
            if let dict = element as? [String: Any] {
                return sanitize(dict)
            } else if let nestedArray = element as? [Any] {
                return sanitizeArray(nestedArray)
            }
            return element
        }
    }

    private func sanitizeMetadataValue(_ value: Logger.MetadataValue) -> Logger.MetadataValue {
        switch value {
        case .dictionary(let dict):
            return .dictionary(sanitize(dict))
        case .array(let array):
            return .array(array.map { sanitizeMetadataValue($0) })
        default:
            return value
        }
    }

    private func maskMetadata(value: Logger.MetadataValue) -> Logger.MetadataValue {
        switch value {
        case .string(let string):
            return .string(String(repeating: maskChar, count: max(string.count, 1)))
        case .stringConvertible(let convertible):
            let str = convertible.description
            return .string(String(repeating: maskChar, count: max(str.count, 1)))
        case .dictionary(let dict):
            return .dictionary(dict.mapValues { maskMetadata(value: $0) })
        case .array(let array):
            return .array(array.map { maskMetadata(value: $0) })
        }
    }
}
