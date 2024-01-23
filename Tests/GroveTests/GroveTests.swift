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
        Grove.defaultContainer.register(NotProtocolConformingTestClass.init)

        let testClass: NotProtocolConformingTestClass = Grove.defaultContainer.resolve()
        XCTAssertEqual(testClass.value, "grove")
    }

    /// Tests registering a class as a protocol and resolving it as a protocol.
    func testClassAsProtocolRegistration() {
        Grove.defaultContainer.register(TestClass.init, type: TestProtocol.self)

        @Resolve var testClass: TestProtocol
        XCTAssertEqual(testClass.value, 0)
    }

    /// Tests registering a class using the transient lifetime scope
    func testTransientScope() {
        Grove.defaultContainer.register(TestClass.init, type: TestProtocol.self, scope: .transient)

        @Resolve var testClass1: TestProtocol
        testClass1.increment()
        testClass1.increment()
        testClass1.increment()
        XCTAssertEqual(testClass1.value, 3)

        let testClass2: TestProtocol = Grove.defaultContainer.resolve()
        XCTAssertEqual(testClass2.value, 0)
    }

    /// Tests registering a class using the singleton lifetime scope
    func testSingletonScope() {
        Grove.defaultContainer.register(TestClass.init, type: TestProtocol.self, scope: .singleton)

        @Resolve var testClass1: TestProtocol
        testClass1.increment()
        testClass1.increment()
        testClass1.increment()
        XCTAssertEqual(testClass1.value, 3)

        @Resolve var testClass2: TestProtocol
        XCTAssertEqual(testClass2.value, 3)
    }
}