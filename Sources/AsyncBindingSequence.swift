//
//  AsyncSequence+BindingSequence.swift
//  AsyncBinding
//
//  Created by Kolos Foltanyi on 2023. 08. 06..
//

/// Maps elements or failures from a base sequence to a Result. The resulting async sequence cannot throw.
public struct AsyncBindingSequence<Base: AsyncSequence>: AsyncSequence {

    public typealias Element = Result<Base.Element, Error>
    public typealias AsyncIterator = Iterator

    public struct Iterator: AsyncIteratorProtocol {
        var base: Base.AsyncIterator

        public mutating func next() async -> Element? {
            do {
                guard let element = try await base.next() else { return nil }
                return .success(element)
            } catch {
                return .failure(error)
            }
        }
    }

    let base: Base

    public func makeAsyncIterator() -> Iterator {
        Iterator(base: base.makeAsyncIterator())
    }
}

// MARK: - AsyncSequence Extensions

public extension AsyncSequence {
    /// Maps elements or failures from a base sequence to a Result.
    ///
    /// The resulting async sequence cannot throw.
    func asBindingSequence() -> AsyncBindingSequence<Self> {
        AsyncBindingSequence(base: self)
    }
}

// MARK: - AsyncBindingSequence + Sendable

extension AsyncBindingSequence: Sendable where Base: Sendable {}
extension AsyncBindingSequence.Iterator: Sendable where Base.AsyncIterator: Sendable {}
