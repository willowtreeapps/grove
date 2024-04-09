# Grove
Simple Swift Dependency Injection Container.
Somewhat like a grove is a group of trees, Grove's container represents a group of dependencies, and it provides you with tools to easily manage them.

## Description
Grove is a super simple and lightweight Dependency Injection library available for Swift. It's designed to help you manage a group of dependencies in a container, and easily resolve them when needed, thus helping make your project more modular, testable, and maintainable.

## Features
- **Lightweight and Focused** - Specifically responsible for dealing with dependency injection.
- **Swift-native Design** - Grove feels natural and intuitive for Swift developers.
- **Scoped Instances** - Capable of setting dependencies' lifetime scope (as singleton or transient).
- **Thread-safe** - Grove maintains thread-safety when registering and resolving dependencies.
- **Simple** - With Grove's `@Resolve` property wrapper, usage is cleaner and super easy.

## Installation
Grove is available through the Swift Package Manager. To install it, simply add the following line to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/willowtreeapps/grove.git", from: "1.1.1")
]
```

## Usage
Grove simplifies dependency registration and resolving. Here's an example:

### Registration

```swift
let container = Grove.defaultContainer // You can use the default container or create your own

// Register specifying a type to use for resolution
container.register(as: NASARepositoryProtocol.self, NASARepository())

// Register a reference type dependency as a singleton 
container.register(JSONEncoder())

// or with a transient lifetime
container.register(scope: .transient, JSONEncoder())

// Register a value type dependency (an enum for example)
container.register(DeploymentEnvironment.production)
```

### Resolution

```swift
// Later in your code, you can resolve the dependency
let jsonEncoder: JSONEncoder = container.resolve()

// Alternatively, you can use the @Resolve property wrapper:
@Resolve(JSONEncoder.self) var jsonEncoder

// Value types are resolved the same way (here deploymentEnvironment would be .production)
@Resolve(DeploymentEnvironment.self) var deploymentEnvironment
```

### Using the included registrar

This shows how you can set up a registrar class both for production and for unit tests and SwiftUI previews:

```swift
import Grove

@main
struct YourApp: App {

    init() {
        GroveRegistrar.register(
            /// Registers dependencies that will be used normally by the app
            baseDependencies: { container in
                container.register(as: Environment.self, Environment.production)
                container.register(as: NASARepositoryProtocol.self, NASARepository())
            },
            /// Registers overrides to be used by the app during development (RUNNING_IN_DEVELOPMENT_MODE environment variable)
            developmentOverrides: { container in
                container.register(as: Environment.self, Environment.local)
                container.register(as: NASARepositoryProtocol.self, MockNASARepository())
            },
            /// Registers overrides to be used by the app during unit tests and swiftui previews 
            unitTestOverrides: { container in
                container.register(as: Environment.self, Environment.local)
                container.register(as: NASARepositoryProtocol.self, MockNASARepository())
            },
            /// Registers dependencies to be used by the app during UI automation tests
            uiAutomationOverrides: { container in
                container.register(as: Environment.self, Environment.mockService)
            }
        )
    }
}
```

## Contributing
Contributions are immensely appreciated. Feel free to submit pull requests or to create issues to discuss any potential bugs or improvements.

## Author
Grove was created by @rafcabezas at [WillowTree, Inc](https://willowtreeapps.com).

## License
Grove is available under the [MIT license](https://opensource.org/licenses/MIT).
