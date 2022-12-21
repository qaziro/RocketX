import SwiftUI
import ComposableArchitecture

struct SnapCarousel: ReducerProtocol {
    struct State: Equatable {
        var currentIndex: Int = 0
        var itemCount: Int = 0
    }
    
    enum Action: Equatable {
        case onGestureEnded(offset: CGFloat, viewWidth: CGFloat)
        case onItemContChanged(count: Int)
        case onIndexChanged(index: Int)
    }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action, Never> {
        switch action {
        case let .onGestureEnded(offset: offset, viewWidth: viewWidth):
            let progress = -offset / viewWidth
            let roundIndex = progress.rounded()
            state.currentIndex = max(min(state.currentIndex + Int(roundIndex), state.itemCount - 1), 0)
            return .run { [index = state.currentIndex] send in
                await send(.onIndexChanged(index: index))
            }
        case .onItemContChanged(count: let count):
            state.itemCount = count
            return .none
        case .onIndexChanged(index: _):
            return .none
        }
    }
}

struct SnapCarouselView<Content: View>: View {
    let store: StoreOf<SnapCarousel>
    var content: Content
    
    @GestureState private var offset: CGFloat = 0
   
    var body: some View {
        WithViewStore(self.store) { viewStore in
            GeometryReader { geo in
                content
                    .offset(x: CGFloat(viewStore.currentIndex) * -geo.size.width + offset)
                    .gesture(
                        DragGesture()
                            .updating($offset, body: { value, out, _ in
                                out = value.translation.width
                            })
                            .onEnded({ value in
                                viewStore.send(.onGestureEnded(offset: value.translation.width, viewWidth: geo.size.width))
                            })
                    )
            }
            .animation(.easeInOut, value: offset == 0)
        }
    }
}

