//
//  GrovePropertyWrapperTests.swift
//  
//
//  Created by Raf Cabezas on 3/7/24.
//

import XCTest
@testable import Grove

fileprivate struct TestStruct {
    var value: Int
}

fileprivate protocol TestProtocol {
    var type: TestStruct { get set }
    var value: Int { get }
    func increment()
}

private final class TestClass: TestProtocol {
    var type: TestStruct

    var value: Int { type.value }

    init(value: Int = 0) {
        self.type = TestStruct(value: value)
    }

    func increment() {
        type.value += 1
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

    func testWritingToPropertyDirectly() {
        // Given
        Grove.defaultContainer.register(as: TestProtocol.self, scope: .singleton, TestClass(value: 10))
        @Resolve(TestProtocol.self) var testClass

        // When
        testClass.type.value = 20

        // Then
        XCTAssertEqual(testClass.value, 20)
    }
}

final class GrovePropertyWrapperAsClassTests: XCTestCase {
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
