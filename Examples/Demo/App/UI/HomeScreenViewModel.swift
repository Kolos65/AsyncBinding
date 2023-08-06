//
//  HomeScreenViewModel.swift
//  AsyncBindingDemo
//
//  Created by Kolos Foltanyi on 2023. 08. 05..
//

import SwiftUI
import Resolver
import Combine

final class HomeScreenViewModel: ObservableObject {

    // MARK: Constants

    private enum Constants {
        static let names = ["John", "Peter", "Adam", "David"]
        static let ages = (0..<100)
        static let colors = [
            ["Red", "Green", "Blue"],
            ["Blue", "Red", "Green"],
            ["Green", "Red", "Blue"]
        ]
    }

    // MARK: Errors

    enum HomeScreenError: Error, LocalizedError {
        case invalidName
        case invalidAge
        case invalidColors
        var errorDescription: String? {
            switch self {
            case .invalidName: return "Invalid name"
            case .invalidAge: return "Invalid age"
            case .invalidColors: return "Invalid colors"
            }
        }
    }

    // MARK: Data

    var name: AsyncThrowingStream<String, Error> {
        .init {
            await Task.sleep(for: 1.5)
            let element = Constants.names.randomElement()
            guard element != "John" else {
                throw HomeScreenError.invalidName
            }
            return element
        }
    }

    var age: AsyncThrowingStream<String, Error> {
        .init {
            await Task.sleep(for: 1.5)
            let element = Constants.ages.randomElement() ?? 0
            guard !(0..<18).contains(element) else {
                throw HomeScreenError.invalidAge
            }
            return String(element)
        }
    }

    var colors: AsyncThrowingStream<[String], Error> {
        .init {
            await Task.sleep(for: 1.5)
            let element = Constants.colors.randomElement()
            guard element != Constants.colors.first else {
                throw HomeScreenError.invalidColors
            }
            return element
        }
    }
}
