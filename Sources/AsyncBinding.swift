//
//  AsyncBinding.swift
//  AsyncBinding
//
//  Created by Kolos Foltanyi on 2023. 08. 05..
//

import SwiftUI

/// An async binding's asynchronous operation.
///
/// Use the `assign(to:)` method of an `AsyncSequence` or the `receive(from:)` method of an `@AsyncBinding` property's projected value to create bindings inside a `bind(_:)` block of a SwiftUI `View`.
public typealias AsyncBindingBlock = @Sendable () async -> Void

/// A `@State` like property wrapper that ebables `View` properties to receive values from an `AsyncSequence` with the same `Element` type.
///
/// In the following example `AsyncSequences` of a `ViewModel` are assigned to `@AsyncBinding` properties of a `View`:
///
///     struct Screen: View {
///
///         @InjectedObject private var viewModel: ViewModel
///
///         @AsyncBinding private var name: String = ""
///         @AsyncBinding private var age: String?
///         @AsyncBinding private var colors: [String]
///
///         var body: some View {
///             VStack {
///                 Text(name)
///                 Text(age ?? "unknown")
///                 Text(colors.joined(separator: ", "))
///                     .foregroundColor($colors.hasError ? .red : .black)
///                 if let error = $colors.error {
///                     Text(error.localizedDescription)
///                 }
///             }
///             .bind {
///                 viewModel.name.assign(to: $name)
///                 viewModel.age.assign(to: $age)
///                 viewModel.colors.assign(to: $colors)
///             }
///         }
///     }
@propertyWrapper
public struct AsyncBinding<Value>: DynamicProperty {

    // MARK: - Private Properties

    private var initial: Value
    @State private var state: Value?
    @State private var errorState: Error?

    // MARK: - Public Properties

    /// The underlying value referenced by the async binding variable.
    ///
    /// This property provides primary access to the value’s data. However, you don’t access wrappedValue directly. Instead, you use the property variable created with the @AsyncBinding attribute. Changes to the wrapped value will trigger a SwiftUI update.
    public var wrappedValue: Value { state ?? initial }

    /// A projection of the async binding value that returns the wrapping instance
    ///
    /// Use the projected value to assign an asynchronous sequences to an @AsyncBinding property or to handle any errors that the underlying sequence produced after binding. To get the projectedValue, prefix the property variable with $.
    public var projectedValue: Self { self }

    /// Indicates whether an error occurred during the execution of the underlying async sequence.
    public var hasError: Bool { errorState != nil  }

    /// Error of the underlying AsyncSequence if it produced one.
    public var error: Error? { errorState }

    // MARK: - Inits

    /// Initializes an `AsyncBinding` object with an empty array as the initial value.
    public init() where Value: ExpressibleByArrayLiteral {
        self.initial = []
    }

    /// Initializes an `AsyncBinding` object with optional element type with nil as the initial value.
    public init() where Value: ExpressibleByNilLiteral {
        self.initial = nil
    }

    /// Initializes an `AsyncBinding` object with the given initial value.
    public init(wrappedValue: Value) {
        self.initial = wrappedValue
    }

    // MARK: - Public methods

    /// Sets the `AsyncBinding` to receive values from an `AsyncSequence`.
    ///
    /// Use this method to create a binding inside a `bind(_:)` block on a SwiftUI `View`.
    public func receive<S: AsyncSequence>(from sequence: S) -> AsyncBindingBlock where S.Element == Value {
        {
            for await result in sequence.asBindingSequence() {
                await setState(from: result)
            }
        }
    }

    /// Sets the `AsyncBinding` with an optional Value to receive values from an `AsyncSequence`.
    ///
    /// Use this method to create a binding inside a `bind(_:)` block on a SwiftUI `View`.
    public func receive<T, S: AsyncSequence>(from sequence: S) -> AsyncBindingBlock where T? == Value, S.Element == T {
        {
            for await result in sequence.asBindingSequence() {
                await setOptionalState(from: result)
            }
        }
    }

    // MARK: - Private Methods

    @MainActor
    private func setState(from result: Result<Value, Error>) {
        switch result {
        case .success(let value):
            state = value
            errorState = nil
        case .failure(let error):
            errorState = error
        }
    }

    @MainActor
    private func setOptionalState<T>(from result: Result<T, Error>) where T? == Value {
        switch result {
        case .success(let value):
            state = value
            errorState = nil
        case .failure(let error):
            errorState = error
        }
    }
}
