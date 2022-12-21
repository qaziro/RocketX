import Foundation
import ComposableArchitecture
import SwiftUI

extension Launch.State {
    init(model: LaunchAPIModel.Mini) {
        self.id = model.id
        self.name = model.name
        self.date = model.dateLocal
        self.success = model.success
    }
}

struct Launch: ReducerProtocol {
    struct State: Equatable, Identifiable {
        var id: String
        var name: String
        var date: Date
        var success: Bool?
    }
    
    enum Action: Equatable {
        case onAppear
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
            }
        }
    }
}

struct LaunchView: View {
    let store: StoreOf<Launch>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            HStack {
                VStack(alignment: .leading) {
                    Text(viewStore.name)
                        .font(.title3)
                    Text(viewStore.date.getFormatedDateText)
                        .foregroundColor(.gray)
                }
                Spacer()
                
                switch viewStore.success {
                case nil:
                    UnknownView()
                case true:
                    SuccessView()
                case false:
                    FailureView()
                case .some(_):
                    EmptyView()
                }
            }
            .frame(maxWidth: .infinity)
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.itemBackground)
            )
        }
    }
}

private struct SuccessView: View {
    var body: some View {
        Image("custom.rocket.portrait")
            .font(.system(size: 40))
            .rotationEffect(.degrees(45))
            .foregroundColor(.gray)
            .overlay(
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.primary, .green)
                    .offset(x: 10, y: 10)
            )
    }
}

private struct FailureView: View {
    var body: some View {
        Image("custom.rocket.portrait")
            .font(.system(size: 40))
            .rotationEffect(.degrees(-135))
            .foregroundColor(.gray)
            .overlay(
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.primary, .red)
                    .offset(x: 10, y: 10)
            )
    }
}

private struct UnknownView: View {
    var body: some View {
        Image("custom.rocket.portrait")
            .font(.system(size: 40))
            .foregroundColor(.gray)
            .overlay(
                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 15))
                    .foregroundStyle(.primary, .gray)
                    .offset(y: -8)
            )
        
    }
}


struct LaunchView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchView(store: Store(
            initialState: Launch.State(id: "0", name: "Launch name", date: Date(), success: true),
                reducer: Launch()
            )
        )
    }
}
