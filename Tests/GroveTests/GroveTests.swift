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
        Grove.defaultContainer.register(NotProtocolConformingTestClass())

        let testClass: NotProtocolConformingTestClass = Grove.defaultContainer.resolve()
        @Resolve var testClass2: TestProtocol
        XCTAssertEqual(testClass.value, "grove")
    }

    /// Tests registering a class as a protocol and resolving it as a protocol.
    func testClassAsProtocolRegistration() {
        Grove.defaultContainer.register(as: TestProtocol.self, TestClass())

        @Resolve var testClass: TestProtocol
        XCTAssertEqual(testClass.value, 0)
    }

    /// Tests registering a class using the transient lifetime scope
    func testTransientScope() {
        Grove.defaultContainer.register(as: TestProtocol.self, scope: .transient, TestClass())

        @Resolve var testClass1: TestProtocol
        testClass1.increment()
        testClass1.increment()
        testClass1.increment()
        XCTAssertEqual(testClass1.value, 3)

        @Resolve var testClass2: TestProtocol
        XCTAssertEqual(testClass2.value, 0)
    }

    /// Tests registering a class using the singleton lifetime scope
    func testSingletonScope() {
        Grove.defaultContainer.register(as: TestProtocol.self, scope: .singleton, TestClass())

        @Resolve var testClass1: TestProtocol
        testClass1.increment()
        testClass1.increment()
        testClass1.increment()
        XCTAssertEqual(testClass1.value, 3)

        @Resolve var testClass2: TestProtocol
        XCTAssertEqual(testClass2.value, 3)
    }
}
