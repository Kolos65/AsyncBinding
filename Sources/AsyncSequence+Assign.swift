//
//  AsyncSequence+Assign.swift
//  AsyncBinding
//
//  Created by Kolos Foltanyi on 2023. 08. 06..
//

extension AsyncSequence {
    /// Assigns values from the `AsyncSequence` to the `AsyncBinding` property.
    ///
    /// Use this method to create a binding inside a `bind(_:)` block on a SwiftUI `View`.
    public func assign(to state: AsyncBinding<Element>) -> AsyncBindingBlock {
        state.receive(from: self)
    }

    /// Assigns optional values from the `AsyncSequence` to the `AsyncBinding` property.
    ///
    /// Use this method to create a binding inside a `bind(_:)` block on a SwiftUI `View`.
    public func assign(to state: AsyncBinding<Element?>) -> AsyncBindingBlock {
        state.receive(from: self)
    }
}
