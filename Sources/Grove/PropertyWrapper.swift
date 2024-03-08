//
//  PropertyWrapper.swift
//  Grove
//
//  Created by Raf Cabezas on 1/24/24.
//

import Foundation

/// Grove resolution property wrapper
///
/// This property wrapper can be used to simplify resolution. Optionally a container other than the default can be specified.
///
/// It allows to resolve dependencies in this fashion:
///  ```
///  @Resolve var jsonEncoder: JSONEncodingProtocol
///  ```
///  This is equivalent to:
///  ```
///  let jsonEncoder: JSONEncodingProtocol = Grove.defaultContainer.resolve()
///  ```
///
@propertyWrapper
public struct Resolve<Dependency> {
    private var container: Grove
    private var transientInstance: Dependency?

    public init(_ type: Dependency.Type, container: Grove = .defaultContainer) {
        self.container = container

        switch container.scope(for: type) {
        case .singleton:
            break
        case .transient:
            transientInstance = (container.resolve() as Dependency)
        }
    }

    public var wrappedValue: Dependency {
        switch container.scope(for: Dependency.self) {
        case .singleton:
            return container.resolve()
        case .transient:
            guard let transientInstance else {
                preconditionFailure("Grove: Error resolving transient dependency: '\(String(describing: Dependency.self))'")
            }
            return transientInstance
        }
    }
}
