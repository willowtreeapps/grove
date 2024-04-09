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
public class Resolve<Dependency>: @unchecked Sendable {
    private let container: Grove
    private let transientInstanceLock = NSLock()
    private var transientInstance: Dependency?

    public init(_ type: Dependency.Type, container: Grove = .defaultContainer) {
        self.container = container
    }

    public var wrappedValue: Dependency {
        get {
            switch container.scope(for: Dependency.self) {
            case .singleton:
                return container.resolve()
            case .transient:
                transientInstanceLock.lock()
                defer {
                    transientInstanceLock.unlock()
                }
                guard let transientInstance else {
                    let transientInstance = (container.resolve() as Dependency)
                    self.transientInstance = transientInstance
                    return transientInstance
                }
                return transientInstance
            }
        }

        set {
            /* No-Op */
        }
    }
}
