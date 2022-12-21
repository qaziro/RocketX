import Foundation
import ComposableArchitecture
import SwiftUI

struct Settings: ReducerProtocol {
    struct State: Equatable {
        var height: LengthType = .m
        var diameter: LengthType = .m
        var mass: WeightType = .kg
        var payloadWeights: WeightType = .kg
    }
    
    enum Action: Equatable {
        case onAppear
        case loadSettings
        case closeButtonTapped
        case setHeight(type: LengthType)
        case setDiameter(type: LengthType)
        case setMass(type: WeightType)
        case setPayloadWeights(type: WeightType)
    }
    
    @Dependency(\.userDefaults) var userDefaults
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    await send(.loadSettings)
                }
            case .loadSettings:
                state.height = userDefaults.heinghtValueType
                state.diameter = userDefaults.diameterValueType
                state.mass = userDefaults.massValueType
                state.payloadWeights = userDefaults.payloadWeightsValueType
                return .none
            case .closeButtonTapped:
                return .none
            case .setHeight(type: let type):
                state.height = type
                return .fireAndForget {
                    await userDefaults.setHeinghtValueType(type)
                }
            case .setDiameter(type: let type):
                state.diameter = type
                return .fireAndForget {
                    await userDefaults.setDiameterValueType(type)
                }
            case .setMass(type: let type):
                state.mass = type
                return .fireAndForget {
                    await userDefaults.setMassValueType(type)
                }
            case .setPayloadWeights(type: let type):
                state.payloadWeights = type
                return .fireAndForget {
                    await userDefaults.setPayloadWeightsValueType(type)
                }
            }
        }
    }
}

struct SettingsView: View {
    let store: StoreOf<Settings>
    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack(alignment: .leading, spacing: 20) {
                ZStack(alignment: .center) {
                    Text(Localazed.settings)
                        .bold()
                    HStack {
                        Spacer()
                        Button(action: {
                            viewStore.send(.closeButtonTapped)
                        }, label: {
                            Text(Localazed.close)
                                .background{
                                    Rectangle().frame(width: 70, height: 70).opacity(0.001) //Increase tap area
                                }
                        })
                        .accessibilityIdentifier("button.close.id")
                    }
                }
                .frame(height: 40)
                
                HStack {
                    Text(Localazed.height)
                    Spacer()
                    Picker("", selection: viewStore.binding(get: \.height, send: Settings.Action.setHeight)) {
                        Text(Localazed.m)
                            .tag(LengthType.m)
                        Text(Localazed.ft)
                            .tag(LengthType.ft)
                    }
                    .accessibilityIdentifier("picker.height.id")
                    .frame(width: 100)
                }
                HStack {
                    Text(Localazed.diameter)
                    Spacer()
                    Picker("", selection: viewStore.binding(get: \.diameter, send: Settings.Action.setDiameter)) {
                        Text(Localazed.m)
                            .tag(LengthType.m)
                        Text(Localazed.ft)
                            .tag(LengthType.ft)
                    }
                    .accessibilityIdentifier("picker.diameter.id")
                    .frame(width: 100)
                }
                HStack {
                    Text(Localazed.mass)
                    Spacer()
                    Picker("", selection: viewStore.binding(get: \.mass, send: Settings.Action.setMass)) {
                        Text(Localazed.kg)
                            .tag(WeightType.kg)
                        Text(Localazed.lb)
                            .tag(WeightType.lb)
                    }
                    .accessibilityIdentifier("picker.mass.id")
                    .frame(width: 100)
                }
                HStack {
                    Text(Localazed.payload_weight)
                    Spacer()
                    Picker("", selection: viewStore.binding(get: \.payloadWeights, send: Settings.Action.setPayloadWeights)) {
                        Text(Localazed.kg)
                            .tag(WeightType.kg)
                        Text(Localazed.lb)
                            .tag(WeightType.lb)
                    }
                    .accessibilityIdentifier("picker.payload.id")
                    .frame(width: 100)
                }
                Spacer()
            }
            .padding(20)
            .pickerStyle(.segmented)
            .buttonStyle(PlainButtonStyle())
            .background(Color.settingsBackground)
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(store: Store(
            initialState: Settings.State(),
                reducer: Settings()
            )
        )
    }
}
