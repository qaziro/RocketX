import Foundation
import ComposableArchitecture
import SwiftUI

struct Main: ReducerProtocol {
    struct State: Equatable {
        var rockets: IdentifiedArrayOf<Rocket.State> = []
        var currentIndex: Int = 0
        var isLoading: Bool = false
        var isLoadingFailed: Bool = false
        var snapCarousel: SnapCarousel.State = .init()
    }
    
    enum Action: Equatable {
        case onAppear
        case loadRockets
        case spacexRocketsApiResponce(TaskResult<[RocketAPIModel.Mini]>)
        case rockets(id: Rocket.State.ID, action: Rocket.Action)
        case snapCarousel(SnapCarousel.Action)
    }
    
    @Dependency(\.spacexClient) var spacexClient
    
    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.snapCarousel, action: /Action.snapCarousel) {
            SnapCarousel()
        }
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    await send(.loadRockets)
                }
            case .loadRockets:
                guard state.rockets.isEmpty else { return .none }
                guard state.isLoading == false else { return .none }
                state.isLoading = true
                state.isLoadingFailed = false
                return .task {
                    await  .spacexRocketsApiResponce(
                        TaskResult { try await spacexClient.getRockets() }
                    )
                }
            case .spacexRocketsApiResponce(.success(let rockets)):
                state.rockets = []
                state.isLoading = false
                
                rockets.forEach {
                    state.rockets.append(Rocket.State(model: $0))
                }
                return .run { [ids = state.rockets.map { $0.id }] send in
                    ids.forEach { id in
                        Task {
                            await send(.rockets(id: id, action: .loadSettings))
                        }
                    }
                    await send(.snapCarousel(.onItemContChanged(count: ids.count)))
                }
            case .spacexRocketsApiResponce(.failure(_)):
                state.isLoading = false
                state.isLoadingFailed = true
                return .none
            case .rockets(id: _, action: .showSettingsTapped(show: let show)):
                if show == false {
                    return .run { [ids = state.rockets.map { $0.id }] send in
                        ids.forEach { id in
                            Task {
                                await send(.rockets(id: id, action: .loadSettings))
                            }
                        }
                    }
                }
                return .none
            case .rockets(id: _, action: _):
                return .none
            case .snapCarousel(.onIndexChanged(index: let index)):
                state.currentIndex = index
                return .none
            case .snapCarousel(_):
                return .none
            }
        }
        .forEach(\.rockets, action: /Action.rockets) {
            Rocket()
        }
    }
}

struct MainView: View {
    let store: StoreOf<Main>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            NavigationView {
                GeometryReader { geo in
                    SnapCarouselView(store: self.store.scope(state: \.snapCarousel, action: Main.Action.snapCarousel), content: (
                        ScrollView(.vertical, showsIndicators: false) {
                            HStack(spacing: 0) {
                                ForEachStore(self.store.scope(state: \.rockets, action: Main.Action.rockets(id:action:))) { rocketStore in
                                    RocketView(store: rocketStore)
                                        .frame(width: geo.size.width)
                                }
                            }
                        }
                        .background(
                            RocketsBackgroundView(store: store, size: geo.size)
                                .offset(y: -30)
                        )
                    ))
                    .overlay( // top safe area background
                        VStack(spacing: 0) {
                            Rectangle()
                                .fill(Material.ultraThinMaterial)
                                .frame(height: geo.safeAreaInsets.top)
                                .frame(maxWidth: .infinity)
                            Spacer()
                        }
                        .offset(y: -geo.safeAreaInsets.top)
                    )
                }
                .onAppear {
                    viewStore.send(.onAppear)
                }
                .overlay (
                    PageIndicatorView(store: store)
                )
                .navigationBarHidden(true)
            }
            .overlay {
                if viewStore.isLoading {
                    LoadingView()
                }
                if viewStore.isLoadingFailed {
                    LoadingFailedView(store: store)
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}

private struct LoadingView: View {
    var body: some View {
        VStack{
            Image("custom.rocket.portrait")
                .font(.system(size: 50))
            ProgressView()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Rectangle()
                .fill(Color.background)
        )
    }
}

private struct LoadingFailedView: View {
    let store: StoreOf<Main>
    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack{
                Button(action: { viewStore.send(.loadRockets)  }, label: {
                    Image(systemName: "arrow.clockwise.circle.fill")
                })
            }
            .font(.system(size: 50))
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                Rectangle()
                    .fill(Color.background)
            )
        }
    }
}

private struct PageIndicatorView: View {
    let store: StoreOf<Main>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            GeometryReader { geo in
                VStack {
                    Spacer()
                    VStack(spacing: 0) {
                        HStack {
                            ForEach(viewStore.rockets.indices, id: \.self) { index in
                                Circle()
                                    .fill(Color.primary)
                                    .frame(width: 10, height: 10)
                                    .opacity(viewStore.currentIndex == index ? 1 : 0.2)
                                    .scaleEffect(viewStore.currentIndex == index ? 1.3 : 1)
                                    .animation(.spring(), value: viewStore.currentIndex == index)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        
                        Spacer()
                            .frame(height: geo.safeAreaInsets.bottom)
                    }
                    .background(
                        Rectangle()
                            .fill(Material.ultraThinMaterial)
                    )
                }
                .offset(y: geo.safeAreaInsets.bottom)
            }
        }
    }
}

private struct RocketsBackgroundView: View {
    let store: StoreOf<Main>
    var size: CGSize
    var body: some View {
        VStack {
            HStack(spacing: 0) {
                ForEachStore(self.store.scope(state: \.rockets, action: Main.Action.rockets(id:action:))) { rocketStore in
                    RocketImageView(store: rocketStore)
                        .frame(width: size.width, height: size.height * 2/3)
                        .clipped()
                }
            }
            Spacer()
        }
    }
}
