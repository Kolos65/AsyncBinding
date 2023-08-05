//
//  AsyncBinding.swift
//  AsyncBinding
//
//  Created by Kolos Foltanyi on 2023. 08. 05..
//

import SwiftUI

/// An async binding's asynchronuknous operation.
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
    public func receive<S: AsyncSequence>(from sequence: S) -> AsyncBindingBlock where S.Element == Value {
        {
            for await value in sequence.asBindingSequence() {
                await setState(from: value)
            }
        }
    }

    /// Sets the `AsyncBinding` with an optional Value to receive values from an `AsyncSequence`.
    public func receive<T, S: AsyncSequence>(from sequence: S) -> AsyncBindingBlock where T? == Value, S.Element == T {
        {
            for await value in sequence.asBindingSequence() {
                await setOptionalState(from: value)
            }
        }
    }

    // MARK: - Private Methods

    @MainActor
    private func setState(from newState: Result<Value, Error>) {
        switch newState {
        case .success(let value):
            state = value
            errorState = nil
        case .failure(let failure):
            errorState = failure
        }
    }

    @MainActor
    private func setOptionalState<T>(from newState: Result<T, Error>) where T? == Value {
        switch newState {
        case .success(let value):
            state = value
            errorState = nil
        case .failure(let failure):
            errorState = failure
        }
    }
}

// MARK: - AsyncSequence Extensions

extension AsyncSequence {
    /// Assigns the values from the `AsyncSequence` to the `AsyncBinding` object.
    public func assign(to state: AsyncBinding<Element>) -> AsyncBindingBlock {
        state.receive(from: self)
    }

    /// Assigns the optional values from the `AsyncSequence` to the `AsyncBinding` object.
    public func assign(to state: AsyncBinding<Element?>) -> AsyncBindingBlock {
        state.receive(from: self)
    }
}

// MARK: - BindingBuilder

/// A result builder that allows for grouping multiple AsyncBindingBlock operations.
@resultBuilder
public enum BindingBuilder {
    public static func buildBlock() -> [AsyncBindingBlock] { [] }
    public static func buildBlock(_ components: AsyncBindingBlock...) -> [AsyncBindingBlock] { components }
}

// MARK: - View Extensions

extension View {
    /// Build block to assign AsyncSeqeunces to @AsyncBinding properties. Bindings are created using the `.task` modifier, which guarantees correct Task cancellations based on the View's lifecycle. See the `.task` modifier for more info.
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
    public func bind(@BindingBuilder _ bindings: @escaping () -> [AsyncBindingBlock]) -> some View {
        task {
            await withTaskGroup(of: Void.self) { group in
                for binding in bindings() {
                    group.addTask(operation: binding)
                }
            }
        }
    }
}

// MARK: - AsyncSequence Extensions

public extension AsyncSequence {
    /// Maps elements or failures from a base sequence to a Result. The resulting async sequence cannot throw.
    func asBindingSequence() -> AsyncBindingSequence<Self> {
        AsyncBindingSequence(base: self)
    }
}

// MARK: - AsyncBindingSequence

/// Maps elements or failures from a base sequence to a Result. The resulting async sequence cannot throw.
public struct AsyncBindingSequence<Base: AsyncSequence>: AsyncSequence {
    public typealias Element = Result<Base.Element, Error>
    public typealias AsyncIterator = Iterator

    let base: Base

    public func makeAsyncIterator() -> Iterator {
        Iterator(
            base: self.base.makeAsyncIterator()
        )
    }

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
}

// MARK: - AsyncBindingSequence + Sendable

extension AsyncBindingSequence: Sendable where Base: Sendable {}
extension AsyncBindingSequence.Iterator: Sendable where Base.AsyncIterator: Sendable {}
