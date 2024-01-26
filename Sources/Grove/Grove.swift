//
//  Grove.swift
//  Grove
//
//  Created by Raf Cabezas on 1/22/24.
//

import Foundation

/// Grove
/// Simple Dependency Injection Container Library
public final class Grove: @unchecked Sendable {

    /// Scope, or lifetime of a reference-type dependency
    public enum Scope {
        /// Dependency is initialized once and then reused. Its lifetime is the lifetime of the container (the app in most cases).
        case singleton
        /// Dependency is initialized every time it is resolved. Its lifetime is the lifetime of the object that owns the dependency.
        case transient
    }

    private enum DependencyItem {
        case initializer(() -> Any, scope: Scope)
        case instance(Any)
    }

    private var dependencyItemsMap = [ObjectIdentifier: DependencyItem]()
    private let dependencyItemsMapLock = NSLock()

    /// Default container
    public static let defaultContainer = Grove()

    /// Public initializer
    public init() { /* No-Op */ }

    /// Registers a dependency's initializer
    /// - Parameters:
    ///   - type: Optional type of to use for registration (ex. JSONEncodingProtocol for the above initializer)
    ///   - scope: Optional scope to use for registration: singleton or transient. Transient dependencies are initialized every time they are resolved
    ///   - initializer: Initializer for the dependency to be registered (ex. JSONEncoder.init, or { JSONEncoder() })
    ///
    public func register<Dependency>(
        _ type: Dependency.Type = Dependency.self,
        scope: Scope = .singleton,
        with initializer: @escaping () -> Dependency
    ) {
        Self.defaultContainerLock.lock()
        Self.defaultContainer = self
        Self.defaultContainerLock.unlock()

        dependencyItemsMapLock.lock()
        dependencyItemsMap[key(for: Dependency.self)] = .initializer(initializer, scope: scope)
        dependencyItemsMapLock.unlock()
    }

    public func register<Dependency>(
        _ initializer: @autoclosure @escaping () -> Dependency,
        as type: Dependency.Type = Dependency.self,
        scope: Scope = .singleton
    ) {
        register(type, scope: scope, with: initializer)
    }

    /// Returns the resolved dependency
    /// - Returns: The resolved dependency
    /// Example: `let jsonEncoder: JSONEncodingProtocol = Grove.defaultContainer.resolve()`
    /// 
    public func resolve<Dependency>() -> Dependency {
        let key = key(for: Dependency.self)

        dependencyItemsMapLock.lock()
        let dependencyItem = dependencyItemsMap[key]
        dependencyItemsMapLock.unlock()

        let dependency: Any

        switch dependencyItem {
        case .initializer(let initializer, let scope):
            dependency = initializer()
            switch scope {
            case .singleton:
                dependencyItemsMapLock.lock()
                dependencyItemsMap[key] = .instance(dependency)
                dependencyItemsMapLock.unlock()
            case .transient:
                // No-Op
                break
            }
        case .instance(let instance):
            dependency = instance
        case .none:
            preconditionFailure("Grove: '\(key)' Not registered.")
        }

        guard let dependency = dependency as? Dependency else {
            preconditionFailure("Grove: '\(key)' stored as '\(dependency.self)' (requested: '\(Dependency.self)').")
        }

        return dependency
    }

    // MARK: Helpers

    private func key<Dependency>(for type: Dependency.Type) -> ObjectIdentifier {
        ObjectIdentifier(type)
    }
}
