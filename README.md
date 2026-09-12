# SwiftLogSanitizer

A structured, high-performance log sanitizer for Swift that redacts sensitive keys and patterns before log emission. Designed to integrate directly with [swift-log](https://github.com/apple/swift-log).

## Features

- **Recursive Key Redaction**: Automatically traverses nested dictionaries and arrays to mask sensitive keys.
- **Pattern Redaction**: Built-in regex detection and redaction for emails, SSNs, and credit card numbers.
- **Swift-Log Integration**: Provides `SanitizedLogHandler` as a drop-in wrapper around any `LogHandler`.
- **Swift 6 Strict Concurrency**: Full `Sendable` conformance and thread safety out of the box.

## Installation

Add `SwiftLogSanitizer` to your `Package.swift` dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/example/swift-log-sanitizer.git", from: "1.0.0"),
]
```

And add it to your target dependencies:

```swift
.target(
    name: "MyApp",
    dependencies: [
        .product(name: "SwiftLogSanitizer", package: "swift-log-sanitizer"),
    ]
)
```

## Quick Start

### Direct Dictionary & Pattern Sanitization

```swift
import SwiftLogSanitizer

let sanitizer = LogSanitizer(sensitiveKeys: ["password", "token"])
let payload: [String: Any] = ["username": "admin", "password": "secretPassword"]
let safePayload = sanitizer.sanitize(payload)

let safeMessage = sanitizer.redactPatterns(in: "User email: user@example.com")
```

### Swift-Log Handler Wrapper

```swift
import Logging
import SwiftLogSanitizer

LoggingSystem.bootstrap { label in
    SanitizedLogHandler(
        handler: StreamLogHandler.standardOutput(label: label),
        sanitizer: LogSanitizer()
    )
}
```

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
