import Foundation
import XCTest
@testable import SwiftLogSanitizer

final class SanitizerTests: XCTestCase {
    func testKeyMasking() {
        let sanitizer = LogSanitizer(sensitiveKeys: ["password", "token"], maskChar: "*")
        let input: [String: Any] = [
            "username": "alice",
            "password": "secretPassword",
            "nested": [
                "token": "tok_12345",
                "role": "admin"
            ]
        ]

        let sanitized = sanitizer.sanitize(input)

        XCTAssertEqual(sanitized["username"] as? String, "alice")
        XCTAssertEqual(sanitized["password"] as? String, "**************")

        let nested = sanitized["nested"] as? [String: Any]
        XCTAssertNotNil(nested)
        XCTAssertEqual(nested?["token"] as? String, "*********")
        XCTAssertEqual(nested?["role"] as? String, "admin")
    }

    func testCustomMaskChar() {
        let sanitizer = LogSanitizer(sensitiveKeys: ["pin"], maskChar: "#")
        let sanitized = sanitizer.sanitize(["pin": "1234", "name": "bob"])
        XCTAssertEqual(sanitized["pin"] as? String, "####")
        XCTAssertEqual(sanitized["name"] as? String, "bob")
    }

    func testPatternRedaction() {
        let sanitizer = LogSanitizer()
        let text = "Contact user@example.com, SSN 123-45-6789, Card 4111-2222-3333-4444"
        let redacted = sanitizer.redactPatterns(in: text)

        XCTAssertFalse(redacted.contains("user@example.com"))
        XCTAssertFalse(redacted.contains("123-45-6789"))
        XCTAssertFalse(redacted.contains("4111-2222-3333-4444"))
        XCTAssertEqual(redacted, "Contact [REDACTED], SSN [REDACTED], Card [REDACTED]")
    }
}
