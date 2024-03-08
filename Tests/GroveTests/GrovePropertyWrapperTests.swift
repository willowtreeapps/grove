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

    func testUpdatedRegistration() {
        // Given
        @Resolve(TestProtocol.self) var testClass
        Grove.defaultContainer.register(as: TestProtocol.self, scope: .singleton, TestClass(value: 10))

        // When
        Grove.defaultContainer.register(as: TestProtocol.self, scope: .singleton, TestClass(value: 20))

        // Then
        XCTAssertEqual(testClass.value, 20)
    }

    func testForTransientScopeDependencies() {
        // Given
        Grove.defaultContainer.register(as: TestProtocol.self, scope: .transient, TestClass(value: 100))
        @Resolve(TestProtocol.self) var testClass
        @Resolve(TestProtocol.self) var testClass2

        // When
        testClass.increment()
        testClass.increment()
        testClass.increment()

        // Then
        XCTAssertEqual(testClass.value, 103)
        XCTAssertEqual(testClass2.value, 100)
    }
}
