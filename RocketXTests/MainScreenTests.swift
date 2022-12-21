import ComposableArchitecture
import XCTest

@testable import RocketX

@MainActor
final class MainScreenTests: XCTestCase {
    let store = TestStore(
        initialState: Main.State(),
        reducer: Main()
    )
    
    func testRocketsLoading() async {
        store.dependencies.userDefaults = .noop
        
        await self.store.send(.loadRockets) {
            $0.rockets = []
            $0.isLoading = true
            $0.isLoadingFailed = false
        }
        
        let rocketData: [RocketAPIModel.Mini] = SpaceXTestHelper.rockets
        var rockets: IdentifiedArrayOf<Rocket.State> = []
        
        rocketData.forEach {
            rockets.append(Rocket.State(model: $0))
        }
        
        await store.receive(.spacexRocketsApiResponce(.success(rocketData))) {
            $0.isLoading = false
            $0.rockets = rockets
        }
    }
}
