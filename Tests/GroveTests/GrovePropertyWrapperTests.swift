//
//  GrovePropertyWrapperTests.swift
//  
//
//  Created by Raf Cabezas on 3/7/24.
//

import XCTest
@testable import Grove

private final class TestClass: TestProtocol {
    var value: Int

    init(value: Int = 0) {
        self.value = value
    }

    func increment() {
        value += 1
    }
}

final class GrovePropertyWrapperTests: XCTestCase {
    @Resolve(TestProtocol.self) private var testClass

    func testUpdatedRegistration() {
        // Given
        Grove.defaultContainer.register(as: TestProtocol.self, scope: .singleton, TestClass(value: 10))

        // When
        Grove.defaultContainer.register(as: TestProtocol.self, scope: .singleton, TestClass(value: 20))

        // Then
        XCTAssertEqual(testClass.value, 20)
    }
}
