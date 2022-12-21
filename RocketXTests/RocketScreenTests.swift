import ComposableArchitecture
import XCTest

@testable import RocketX

@MainActor
final class RocketScreenTests: XCTestCase {
    let store: TestStore = {
        var rocket = Rocket.State(model: SpaceXTestHelper.rockets.first!)
        rocket.height.type = .ft
        rocket.diameter.type = .ft
        rocket.mass.type = .lb
        rocket.payloadWeights.type = .lb
        return TestStore(initialState: rocket, reducer: Rocket())
    }()
    
    func testRocketSettings() async {
        store.dependencies.userDefaults = .noop
        
        await self.store.send(.loadSettings) {
            $0.height.type = .m
            $0.diameter.type = .m
            $0.mass.type = .kg
            $0.payloadWeights.type = .kg
        }
        
        await self.store.send(.showSettingsTapped(show: true)) {
            $0.showSettings = true
        }
        
        await self.store.send(.showSettingsTapped(show: false)) {
            $0.showSettings = false
        }
        
    }
    
    func testRocketLaunches() async {
        await self.store.send(.showLaunchesTapped(show: true)) {
            $0.showLaunches = true
            $0.launchList = .init(rocketID: $0.id, rocketName: $0.name)
        }
        
        await self.store.send(.showLaunchesTapped(show: false)) {
            $0.showLaunches = false
        }
        
    }
}
