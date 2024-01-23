//
//  PropertyWrapper.swift
//  Grove
//
//  Created by Raf Cabezas on 1/24/24.
//

import Foundation

/// Grove resolution property wrapper
///
/// In most cases, where only a single container is used, this property wrapper can be used to simplify resolution.
///
/// Allows to resolve dependencies in this fashion:
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

    public init() {
        self.wrappedValue = Grove.defaultContainer.resolve()
    }
}
