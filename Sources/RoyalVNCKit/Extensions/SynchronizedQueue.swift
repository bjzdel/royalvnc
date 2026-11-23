#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// A FIFO queue that can be used from multiple threads at the same time.
///
/// Client-to-server messages (key, pointer, clipboard, pixel format) are enqueued
/// from the caller's thread (usually the main thread) while the send loop dequeues
/// them from a background task. A plain `Queue` (an `Array`) is not safe for that,
/// so every access here is serialized with a lock.
final class SynchronizedQueue<T>: @unchecked Sendable {
#if canImport(Glibc) || canImport(Android) || canImport(WinSDK)
    private let lock = Spinlock()
#else
    private let lock = NSLock()
#endif

    private var queue = Queue<T>()

    init() { }

    func enqueue(_ element: T) {
        lock.lock()
        defer { lock.unlock() }

        queue.enqueue(element)
    }

    func dequeue() -> T? {
        lock.lock()
        defer { lock.unlock() }

        return queue.dequeue()
    }

    func clear() {
        lock.lock()
        defer { lock.unlock() }

        queue.clear()
    }

    func peek() -> T? {
        lock.lock()
        defer { lock.unlock() }

        return queue.peek()
    }

    var isEmpty: Bool {
        lock.lock()
        defer { lock.unlock() }

        return queue.isEmpty
    }
}
