//
//  View+Bind.swift
//  AsyncBinding
//
//  Created by Kolos Foltanyi on 2023. 08. 06..
//

import SwiftUI

extension View {
    /// Build block to assign `AsyncSequences` to `@AsyncBinding` properties. Bindings are created using the `.task` modifier, which guarantees correct Task cancellations based on the View's lifecycle. See the `.task` modifier for more info.
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
    public func bind(@AsyncBindingBuilder _ bindings: @escaping () -> [AsyncBindingBlock]) -> some View {
        task {
            await withTaskGroup(of: Void.self) { group in
                for binding in bindings() {
                    group.addTask(operation: binding)
                }
            }
        }
    }
}
