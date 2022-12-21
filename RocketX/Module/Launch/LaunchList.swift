import Foundation
import ComposableArchitecture
import SwiftUI

struct LaunchList: ReducerProtocol {
    struct State: Equatable {
        var rocketID: String
        var rocketName: String
        var launches: IdentifiedArrayOf<Launch.State> = []
        var isLoading: Bool = false
        var isLoadingFailed: Bool = false
    }
    
    enum Action: Equatable {
        case onAppear
        case onDisappear
        case loadLaunches
        case launches(id: Launch.State.ID, action: Launch.Action)
        case spacexLaunchesApiResponce(TaskResult<[LaunchAPIModel.Mini]>)
    }
    
    @Dependency(\.spacexClient) var spacexClient
    
    enum SpaceXApiID {}
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    await send(.loadLaunches)
                }
            case .onDisappear:
                return .cancel(id: SpaceXApiID.self)
            case .loadLaunches:
                state.isLoading = true
                state.isLoadingFailed = false
                let rocketID = state.rocketID
                return .task {
                    await  .spacexLaunchesApiResponce(
                        TaskResult { try await spacexClient.getLaunchesFor(rocketID) }
                    )
                }
                .cancellable(id: SpaceXApiID.self, cancelInFlight: true)
            case .launches(id: _, action: _):
                return .none
            case .spacexLaunchesApiResponce(.success(let launches)):
                state.launches = []
                state.isLoading = false
                state.isLoadingFailed = false
                launches.forEach {
                    state.launches.append(Launch.State(model: $0))
                }
                return .none
            case .spacexLaunchesApiResponce(.failure):
                state.isLoading = false
                state.isLoadingFailed = true
                return .none
            }
        }
        .forEach(\.launches, action: /Action.launches) {
            Launch()
        }
    }
}

struct LaunchListView: View {
    let store: StoreOf<LaunchList>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            ScrollView(.vertical) {
                LazyVStack(spacing: 20) {
                    ForEachStore(self.store.scope(state: \.launches, action: LaunchList.Action.launches(id:action:))) { launchStore in
                        WithViewStore(launchStore) { launchViewStore in
                            LaunchView(store: launchStore)
                        }
                    }
                    Spacer()
                }
                .padding(20)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(viewStore.rocketName)
            .onAppear {
                viewStore.send(.onAppear)
            }
            .onDisappear {
                viewStore.send(.onDisappear)
            }
            .overlay {
                if viewStore.isLoading {
                    LoadingView()
                }
                if viewStore.isLoadingFailed || viewStore.launches.isEmpty && viewStore.isLoading == false {
                    LoadingFailedView()
                }
            }
        }
    }
}

private struct LoadingView: View {
    var body: some View {
        VStack{
            Image("custom.rocket.portrait")
                .font(.system(size: 50))
            ProgressView()
        }
    }
}

private struct LoadingFailedView: View {
    var body: some View {
        VStack{
            Text(Localazed.no_launches_found)
                .foregroundColor(.gray)
        }
    }
}

struct LaunchListView_Previews: PreviewProvider {
    static var launches: IdentifiedArrayOf<Launch.State> = [
        .init(id: "0", name: "Launch 01", date: Date(), success: nil),
        .init(id: "1", name: "Launch 02", date: Date(), success: false),
        .init(id: "3", name: "Launch 03", date: Date(), success: true)
    ]
    
    static var previews: some View {
        LaunchListView(store: Store(
            initialState: LaunchList.State(rocketID: "123", rocketName: "Rocket name", launches: launches),
                reducer: LaunchList()
            )
        )
    }
}
