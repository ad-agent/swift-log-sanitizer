import Foundation
import Logging

/// A log handler wrapper that sanitizes metadata before forwarding log events.
public struct SanitizedLogHandler: LogHandler, Sendable {
    private var handler: any LogHandler
    public var sanitizer: LogSanitizer

    public init(handler: any LogHandler, sanitizer: LogSanitizer = LogSanitizer()) {
        self.handler = handler
        self.sanitizer = sanitizer
    }

    public var logLevel: Logger.Level {
        get { handler.logLevel }
        set { handler.logLevel = newValue }
    }

    public var metadataProvider: Logger.MetadataProvider? {
        get { handler.metadataProvider }
        set { handler.metadataProvider = newValue }
    }

    public var metadata: Logger.Metadata {
        get { handler.metadata }
        set { handler.metadata = sanitizer.sanitize(newValue) }
    }

    public subscript(metadataKey key: String) -> Logger.Metadata.Value? {
        get { handler[metadataKey: key] }
        set {
            if let newValue {
                let sanitized = sanitizer.sanitize([key: newValue])
                handler[metadataKey: key] = sanitized[key]
            } else {
                handler[metadataKey: key] = nil
            }
        }
    }

    public func log(
        level: Logger.Level,
        message: Logger.Message,
        metadata: Logger.Metadata?,
        source: String,
        file: String,
        function: String,
        line: UInt
    ) {
        log(
            event: LogEvent(
                level: level,
                message: message,
                metadata: metadata,
                source: source,
                file: file,
                function: function,
                line: line
            )
        )
    }

    public func log(event: LogEvent) {
        var sanitizedEvent = event
        if let metadata = event.metadata {
            sanitizedEvent.metadata = sanitizer.sanitize(metadata)
        }
        handler.log(event: sanitizedEvent)
    }
}
