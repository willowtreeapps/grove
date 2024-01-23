//
//  Grove.swift
//  Grove
//
//  Created by Raf Cabezas on 1/22/24.
//

import Foundation

/// Grove
/// Simple Dependency Injection Container Library
public final class Grove {

    /// Scope, or lifetime of a dependency
    public enum Scope {
        // singleton: dependency is initialized once and then reused. Its lifetime is the lifetime of the container (the app in most cases).
        // transient: dependency is initialized every time it is resolved. Its lifetime is the lifetime of the object that owns the dependency.
        case singleton, transient
    }

    private enum DependencyItem {
        case initializer(() -> AnyObject, scope: Scope)
        case instance(AnyObject)
    }
    private var dependencyItemsMap = [String: DependencyItem]()
    private let dependencyItemsMapLock = NSLock()
    public private(set) static var defaultContainer = Grove()
    private static let defaultContainerLock = NSLock()
    public init() {}

    /// Registers a dependency's initializer
    /// - Parameters:
    ///   - initializer: Initializer for the dependency to be registered (ex. JSONEncoder.init, or { JSONEncoder() })
    ///   - type: Optional type of to use for registration (ex. JSONEncodingProtocol for the above initializer)
    ///   - scope: Optional scope to use for registration: singleton or transient. Transient dependencies are initialized every time they are resolved
    ///
    public func register<T>(_ initializer: @escaping () -> AnyObject, type: T.Type = T.self, scope: Scope = .singleton) {
        Self.defaultContainerLock.lock()
        Self.defaultContainer = self
        Self.defaultContainerLock.unlock()

        dependencyItemsMapLock.lock()
        dependencyItemsMap[key(for: T.self)] = DependencyItem.initializer(initializer, scope: scope)
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

        let objectInstance: AnyObject
        switch dependencyItem {
        case .initializer(let initializer, let scope):
            objectInstance = initializer()
            switch scope {
            case .singleton:
                dependencyItemsMapLock.lock()
                dependencyItemsMap[key] = DependencyItem.instance(objectInstance)
                dependencyItemsMapLock.unlock()
            case .transient:
                // No-Op
                break
            }
        case .instance(let instance):
            objectInstance = instance
        case .none:
            preconditionFailure("Grove: '\(key)' Not registered.")
        }

        guard let objectInstance = objectInstance as? T else {
            preconditionFailure("Grove: '\(key)' stored as '\(objectInstance.self)' (requested: '\(T.self)').")
        }

        return objectInstance
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

    public func register<T>(_ initializer: @escaping () -> T, scope: Scope = .singleton) where T: AnyObject {
        register(initializer, type: T.self, scope: scope)
    }
}
