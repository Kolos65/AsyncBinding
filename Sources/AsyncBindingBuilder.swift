//
//  AsyncBindingBuilder.swift
//  AsyncBinding
//
//  Created by Kolos Foltanyi on 2023. 08. 06..
//

/// A result builder that allows for grouping multiple AsyncBindingBlock operations.
///
/// Use the `assign(to:)` method of an `AsyncSequence` or the `receive(from:)` method of an `@AsyncBinding` property's projected value to create bindings inside a `bind(_:)` block of a SwiftUI `View`.
@resultBuilder
public enum AsyncBindingBuilder {
    public static func buildBlock() -> [AsyncBindingBlock] { [] }
    public static func buildBlock(_ components: AsyncBindingBlock...) -> [AsyncBindingBlock] { components }
}
