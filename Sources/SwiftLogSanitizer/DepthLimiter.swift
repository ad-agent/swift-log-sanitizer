import Foundation
/// Depth limiter for recursive sanitization to prevent stack overflow.
public struct DepthLimiter: Sendable {
    public let maxDepth: Int
    public init(maxDepth: Int = 10) { self.maxDepth = maxDepth }
    public func isWithinLimit(_ current: Int) -> Bool { current < maxDepth }
}
