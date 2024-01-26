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
        // singleton: dependency is initialized once and then reused. Its lifetime is the lifetime of the container (the app in most cases).
        // transient: dependency is initialized every time it is resolved. Its lifetime is the lifetime of the object that owns the dependency.
        case singleton, transient
    }

    private enum DependencyItem {
        case initializer(() -> Any, scope: Scope)
        case instance(Any)
    }
    private var dependencyItemsMap = [String: DependencyItem]()
    private let dependencyItemsMapLock = NSLock()
    private static let defaultContainerLock = NSLock()

    /// Default container
    public private(set) static var defaultContainer = Grove()

    /// Public initializer
    public init() { /* No-Op */ }

    /// Registers a dependency's initializer
    /// - Parameters:
    ///   - type: Optional type of to use for registration (ex. JSONEncodingProtocol for the above initializer)
    ///   - scope: Optional scope to use for registration: singleton or transient. Transient dependencies are initialized every time they are resolved
    ///   - initializer: Initializer for the dependency to be registered (ex. JSONEncoder.init, or { JSONEncoder() })
    ///
    public func register<T>(as type: T.Type = T.self, scope: Scope = .singleton, _ initializer: @escaping () -> T) {
        Self.defaultContainerLock.lock()
        Self.defaultContainer = self
        Self.defaultContainerLock.unlock()

        dependencyItemsMapLock.lock()
        dependencyItemsMap[key(for: T.self)] = DependencyItem.initializer(initializer, scope: scope)
        dependencyItemsMapLock.unlock()
    }

    /// Registers using a value
    /// - Parameters:
    ///   - type: Optional type of to use for registration
    ///   - value: Value for the dependency to be registered
    ///
    public func register<T>(as type: T.Type = T.self, value: T) {
        Self.defaultContainerLock.lock()
        Self.defaultContainer = self
        Self.defaultContainerLock.unlock()

        dependencyItemsMapLock.lock()
        dependencyItemsMap[key(for: T.self)] = DependencyItem.instance(value)
        dependencyItemsMapLock.unlock()
    }

    /// Returns the resolved dependency
    /// - Returns: The resolved dependency
    /// Example: `let jsonEncoder: JSONEncodingProtocol = Grove.defaultContainer.resolve()`
    /// 
    public func resolve<T>() -> T {
        let key = key(for: T.self)
        dependencyItemsMapLock.lock()
        let dependencyItem = dependencyItemsMap[key]
        dependencyItemsMapLock.unlock()

        switch dependencyItem {
        case .initializer(let initializer, let scope):
            let objectInstance = initializer()
            switch scope {
            case .singleton:
                dependencyItemsMapLock.lock()
                dependencyItemsMap[key] = DependencyItem.instance(objectInstance)
                dependencyItemsMapLock.unlock()
            case .transient:
                // No-Op
                break
            }
            guard let objectInstance = objectInstance as? T else {
                preconditionFailure("Grove: '\(key)' stored as '\(objectInstance.self)' (requested: '\(T.self)').")
            }
            return objectInstance
        case .instance(let instance):
            guard let instance = instance as? T else {
                preconditionFailure("Grove: '\(key)' stored as '\(instance.self)' (requested: '\(T.self)').")
            }
            return instance
        case .none:
            preconditionFailure("Grove: '\(key)' Not registered.")
        }
    }

    // MARK: Helpers

    private func key<T>(for type: T.Type) -> String {
        let rawKey = String(describing: T.self)
        if !rawKey.hasPrefix("Optional<") {
            return rawKey
                .replacingOccurrences(of: "Optional<", with: "")
                .replacingOccurrences(of: ">", with: "")
        } else {
            return rawKey
        }
    }

    public func register<T>(_ initializer: @escaping () -> T, scope: Scope = .singleton) {
        register(as: T.self, scope: scope, initializer)
    }
}
