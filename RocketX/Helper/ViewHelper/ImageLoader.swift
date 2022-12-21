import SwiftUI
import ComposableArchitecture

struct ImageLoader: ReducerProtocol {
    struct State: Equatable {
        var url: URL
        var image: UIImage?
        var isLoading: Bool = false
        var isLoadingFailed: Bool = false
    }
    
    enum Action: Equatable {
        case onAppear
        case load
        case imageLoaderResponce(TaskResult<UIImage>)
    }
    
    @Dependency(\.imageLoader) var imageLoader
    
    func reduce(into state: inout State, action: Action) -> Effect<Action, Never> {
        switch action {
        case .onAppear:
            return .run { send in
                await send(.load)
            }
        case .load:
            state.isLoading = true
            state.isLoadingFailed = false
            let url = state.url
            return .task {
                await  .imageLoaderResponce(
                    TaskResult { try await imageLoader.load(url) }
                )
            }
        case .imageLoaderResponce(.success(let image)):
            state.image = image
            state.isLoading = false
            state.isLoadingFailed = false
            return .none
        case .imageLoaderResponce(.failure(let error)):
            print("Failed to load image from url \(state.url) with error: \(error)")
            state.isLoading = false
            state.isLoadingFailed = true
            return .none
        }
    }
}

struct ImageLoaderView: View {
    let store: StoreOf<ImageLoader>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            Group {
                if let image = viewStore.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                }
                if viewStore.isLoading {
                    ProgressView()
                }
                if viewStore.isLoadingFailed {
                    Text("No image")
                        .foregroundColor(.gray)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct ImageLoaderView_Previews: PreviewProvider {
    static let url = URL(string: "https://via.placeholder.com/150")!
    static var previews: some View {
        ImageLoaderView(store: Store(
            initialState: ImageLoader.State(url: url),
                reducer: ImageLoader()
            )
        )
    }
}
