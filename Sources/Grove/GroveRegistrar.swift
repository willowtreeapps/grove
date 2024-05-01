//
//  GroveRegistrar.swift
//
//
//  Created by Raf Cabezas on 4/3/24.
//

import Foundation

public struct GroveRegistrar {
    public static func register(
        container: Grove = .defaultContainer,
        developmentModeEnvironmentVariable: String = "RUNNING_IN_DEVELOPMENT_MODE",
        baseDependencies: (Grove) -> Void,
        developmentOverrides: ((Grove) -> Void)? = nil,
        unitTestOverrides: ((Grove) -> Void)? = nil,
        uiAutomationOverrides: ((Grove) -> Void)? = nil
    ) {
        container.reset()
        baseDependencies(container)

        switch RunState(developmentModeEnvironmentVariable: developmentModeEnvironmentVariable) {
        case .app:
            break
        case .development:
            developmentOverrides?(container)
        case .unitTests:
            unitTestOverrides?(container)
        case .uiAutomation:
            uiAutomationOverrides?(container)
        }
    }
}

private enum RunState {
    case app
    case development
    case unitTests
    case uiAutomation

    init(developmentModeEnvironmentVariable: String) {
        if Self.isRunningUIAutomationTests {
            self = .uiAutomation
        } else if Self.isRunningUnitTests {
            self = .unitTests
        } else if Self.isRunningInDevelopmentMode(envVariable: developmentModeEnvironmentVariable) {
            self = .development
        } else {
            self = .app
        }
    }

    /// Is the app running in development mode
    private static func isRunningInDevelopmentMode(envVariable: String) -> Bool {
        ProcessInfo.processInfo.environment[envVariable] != nil
    }

    /// Is the app running unit tests or is in a SwiftUI preview
    private static var isRunningUnitTests: Bool {
        (ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil) || (ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1")
    }

    /// Is the app running UI Automation tests
    private static var isRunningUIAutomationTests: Bool {
        ProcessInfo.processInfo.environment["RUNNING_UI_AUTOMATION"] != nil
    }
}
