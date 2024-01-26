//
//  GroveValueTypeDependencyTests.swift
//  
//
//  Created by Raf Cabezas on 1/26/24.
//

import XCTest
@testable import Grove

private protocol TestEnumProtocol {
    var value: String { get }
}

private enum TestEnum: String, TestEnumProtocol {
    case g, r, o, v, e

    var value: String { rawValue }
}

private enum NotProtocolConformingTestEnum {
    case a, b, c
}

final class GroveValueTypeDependencyTests: XCTestCase {

    /// Tests registering a value type and resolving it.
    func testDirectTypeRegistration() {
        Grove.defaultContainer.register(value: NotProtocolConformingTestEnum.b)

        let testEnum: NotProtocolConformingTestEnum = Grove.defaultContainer.resolve()
        XCTAssertEqual(testEnum, .b)
    }

    /// Tests registering a value type as a protocol and resolving it as a protocol.
    func testValueTypeAsProtocolRegistration() {
        Grove.defaultContainer.register(value: TestEnum.v, type: TestEnumProtocol.self)

        @Resolve var testEnum: TestEnumProtocol
        XCTAssertEqual(testEnum.value, "v")
    }
}