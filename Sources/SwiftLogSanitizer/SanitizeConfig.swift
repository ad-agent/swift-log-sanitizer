/// Configuration for the log sanitizer.
public struct SanitizeConfig: Sendable {
    public let sensitiveKeys: Set<String>
    public let maskCharacter: Character
    public let maskLength: Int
    public init(sensitiveKeys: Set<String> = ["password", "secret", "token", "authorization"], maskCharacter: Character = "*", maskLength: Int = 8) {
        self.sensitiveKeys = sensitiveKeys
        self.maskCharacter = maskCharacter
        self.maskLength = maskLength
    }
    public var mask: String { String(repeating: maskCharacter, count: maskLength) }
}
