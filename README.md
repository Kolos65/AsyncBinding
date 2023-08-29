# AsyncBinding

<p align="left">
<img src="https://img.shields.io/badge/platforms-iOS%2C%20macOS%2C%20watchOS%2C%20tvOS-lightgrey.svg">
</p>

A lightweight Swift package providing a utility for binding **async sequences** to state variables in **SwiftUI**. `AsyncBinding` offers an intuitive way to manage asynchronous data streams and **handle errors** in your SwiftUI views.

## Features

- **Bind** values from **async sequences** to a custom state variable that automatically triggers UI updates when the value changes. Bindings are created using the [`task(priority:_:)`](https://developer.apple.com/documentation/swiftui/view/task(priority:_:)) view modifier that ensures a **binding lifetime** that matches that of the modified view.
- **Handle errors** thrown by async sequences. Graceful error handling is achieved by mapping the underlying async seqeunces to non-throwing sequences with [**`Result`**](https://developer.apple.com/documentation/swift/result) element type.

## Installation

AsyncBinding supports [Swift Package Manager](https://www.swift.org/package-manager/), which is the recommended option.

## Usage

Given a **`ViewModel`** that exposes **async sequences** as follows:

```swift
class ViewModel {
    var name: AsyncThrowingStream<String, Error> { ... }
    var age: AsyncThrowingStream<String, Error> { ... }
    var colors: AsyncThrowingStream<String, Error> { ... }
}
```

You can bind those async sequences to properties in your SwiftUI **`View`** that are marked with a custom property wrapper called **`@AsyncBinding`** using a single line of code and the **`bind(_:)`** modifier:

```swift
struct Screen: View {

    @InjectedObject var viewModel: ViewModel

    @AsyncBinding var name: String = ""
    @AsyncBinding var age: String?
    @AsyncBinding var colors: [String]

    var body: some View {
        VStack {
            Text(name)
            Text(age ?? "unknown")
            Text(colors.joined(separator: ", "))
                .foregroundColor($colors.hasError ? .red : .black)
            if let error = $colors.error {
                Text(error.localizedDescription)
            }
        }
        .bind {
            viewModel.name.assign(to: $name)
            viewModel.age.assign(to: $age)
            viewModel.colors.assign(to: $colors)
        }
    }
}
```

## Error Handling

`AsyncBinding` captures and stores any **errors thrown** by the bound async sequence. You can verify if an error occurred using the **`hasError`** property and retrieve the error through the **`error`** property of the **`projectedValue`** of an **`@AsyncBinding`** property:

```swift
Text(colors.joined(separator: ", "))
    .foregroundColor($colors.hasError ? .red : .black)
if let error = $colors.error {
    Text(error.localizedDescription)
}
```

`AsyncBinding` uses a custom sequence called **`AsyncBindingSequence`** under the hood to wrap the base sequence's values with a [**`Result`**](https://developer.apple.com/documentation/swift/result) type, thus creating a new sequence that **cannot throw**. This allows the base sequences to **remain active** even if an error was thrown. `AsyncBindingSequence` is inspired by `AsyncMapToResultSequence` from the [AsyncExtensions](https://github.com/sideeffect-io/AsyncExtensions) package.

## Demo Application
The package contains a demo project for a comprehensive example of how to use **`AsyncBinding`**. Note that the demo project uses [XcodeGen](https://github.com/yonaskolb/XcodeGen) to generate the project file. See the `README.md` inside the demo project for more info.

## Contributing

Feel free to submit a pull request or open an issue.

## License

`AsyncBinding` is made available under the MIT License. Please see the LICENSE file for more details.
