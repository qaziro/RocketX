import ComposableArchitecture
import XCTest

@testable import RocketX

@MainActor
final class SettingsScreenTests: XCTestCase {
    let store = TestStore(
        initialState: Settings.State(),
        reducer: Settings()
    )
    
    func testSettings() async {
        store.dependencies.userDefaults = .noop
        
        await self.store.send(.setMass(type: .lb)) {
            $0.mass = .lb
        }
        
        await self.store.send(.setPayloadWeights(type: .lb)) {
            $0.payloadWeights = .lb
        }
        
        await self.store.send(.setHeight(type: .ft)) {
            $0.height = .ft
        }
        
        await self.store.send(.setDiameter(type: .ft)) {
            $0.diameter = .ft
        }
        
        await self.store.send(.loadSettings) {
            $0.mass = .kg
            $0.payloadWeights = .kg
            $0.height = .m
            $0.diameter = .m
        }
    }
}
