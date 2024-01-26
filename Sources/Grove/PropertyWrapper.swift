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
public struct Resolve<T> {
    public var wrappedValue: T

    public init(container: Grove = .defaultContainer) {
        self.wrappedValue = container.resolve()
    }
}
