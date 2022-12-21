import ComposableArchitecture
import XCTest

@testable import RocketX

@MainActor
final class LaunchListScreenTests: XCTestCase {
    let store = TestStore(
        initialState: LaunchList.State(
            rocketID: "007",
            rocketName: "Rocket07"),
        reducer: LaunchList()
    )
    
    func testLaunchesLoading() async {
        await self.store.send(.loadLaunches) {
            $0.launches = []
            $0.isLoading = true
            $0.isLoadingFailed = false
        }
        
        let lanuchData: [LaunchAPIModel.Mini] = SpaceXTestHelper.launches
        var launches: IdentifiedArrayOf<Launch.State> = []
        
        lanuchData.forEach {
            launches.append(Launch.State(model: $0))
        }
        
        await store.receive(.spacexLaunchesApiResponce(.success(lanuchData))) {
            $0.isLoading = false
            $0.launches = launches
        }
    }
}
