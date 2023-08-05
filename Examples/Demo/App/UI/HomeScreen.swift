//
//  HomeScreen.swift
//  AsyncBindingDemo
//
//  Created by Kolos Foltanyi on 2023. 08. 05..
//

import SwiftUI
import Resolver
import AsyncBinding

struct HomeScreen: View {

    // MARK: Injected properties

    @InjectedObject private var viewModel: HomeScreenViewModel

    // MARK: Private properties

    @AsyncBinding private var name: String = ""
    @AsyncBinding private var age: String?
    @AsyncBinding private var colors: [String]

    private var colorList: String {
        colors.joined(separator: " ")
    }

    // MARK: UI

    var body: some View {
        NavigationView {
            Grid {
                gridRows
            }
            .navigationTitle("AsyncBinding")
        }
        .bind {
            viewModel.name.assign(to: $name)
            viewModel.age.assign(to: $age)
            viewModel.colors.assign(to: $colors)
        }
    }

    @ViewBuilder
    private var gridRows: some View {
        renderRow(
            title: "Name",
            value: name,
            error: $name.error,
            hasError: $name.hasError
        )
        if let age {
            Divider()
            renderRow(
                title: "Age",
                value: age,
                error: $age.error,
                hasError: $age.hasError
            )
        }
        Divider()
        renderRow(
            title: "Colors",
            value: colorList,
            error: $colors.error,
            hasError: $colors.hasError
        )
    }

    private func renderRow(title: String,
                           value: String,
                           error: Error?,
                           hasError: Bool) -> some View {
        GridRow {
            Text(title)
                .font(.system(size: 16, weight: .bold))
            Text(value)
                .font(.system(size: 16, weight: .regular))
                .opacity(hasError ? 0.3 : 1) // Yes we could've used error == nil here
            if let error {
                Text(error.localizedDescription)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.red)
            } else {
                Text("No error")
                    .font(.system(size: 16, weight: .regular))
                    .opacity(0.3)
            }
        }
        .frame(height: 50)
        .frame(maxWidth: .infinity)
    }
}
