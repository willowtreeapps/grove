import XCTest
@testable import Grove

private protocol TestProtocol {
    var value: Int { get }
    func increment()
}

private final class TestClass: TestProtocol {
    var value: Int = 0

    func increment() {
        value += 1
    }
}

private final class NotProtocolConformingTestClass {
    var value = "grove"
}

final class GroveTests: XCTestCase {

    /// Tests registering a class and resolving it.
    func testDirectClassRegistration() {
        //Given
        Grove.defaultContainer.register(NotProtocolConformingTestClass())

        // When
        let testClass: NotProtocolConformingTestClass = Grove.defaultContainer.resolve()

        // Then
        XCTAssertEqual(testClass.value, "grove")
    }

    /// Tests registering a class as a protocol and resolving it as a protocol.
    func testClassAsProtocolRegistration() {
        // Given
        Grove.defaultContainer.register(as: TestProtocol.self, TestClass())

        // When
        let testClass: TestProtocol = Grove.defaultContainer.resolve()

        // Then
        XCTAssertEqual(testClass.value, 0)
    }

    /// Tests registering a class using the transient lifetime scope
    func testTransientScope() {
        // Given
        Grove.defaultContainer.register(as: TestProtocol.self, scope: .transient, TestClass())
        let testClass1: TestProtocol = Grove.defaultContainer.resolve()

        // When
        testClass1.increment()
        testClass1.increment()
        testClass1.increment()

        // Then
        XCTAssertEqual(testClass1.value, 3)
        let testClass2: TestProtocol = Grove.defaultContainer.resolve()
        XCTAssertEqual(testClass2.value, 0)
    }

    /// Tests registering a class using the singleton lifetime scope
    func testSingletonScope() {
        // Given
        Grove.defaultContainer.register(as: TestProtocol.self, scope: .singleton, TestClass())
        let testClass1: TestProtocol = Grove.defaultContainer.resolve()

        // When
        testClass1.increment()
        testClass1.increment()
        testClass1.increment()

        // Then
        XCTAssertEqual(testClass1.value, 3)
        let testClass2: TestProtocol = Grove.defaultContainer.resolve()
        XCTAssertEqual(testClass2.value, 3)
    }
}
