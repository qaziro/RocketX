import Foundation
import ComposableArchitecture
import SwiftUI

extension Rocket.State {
    init(model: RocketAPIModel.Mini) {
        let payloadWeightLEO = model.payloadWeights.first(where: { $0.id == "leo" })
        
        self.id = model.id
        self.name = model.name
        self.height = Length(m: model.height.meters ?? 0, ft: model.height.feet ?? 0)
        self.diameter = Length(m: model.diameter.meters ?? 0, ft: model.diameter.feet ?? 0)
        self.mass = Weight(kg: Double(model.mass.kg), lb: Double(model.mass.lb))
        self.payloadWeights = Weight(kg: Double(payloadWeightLEO?.kg ?? 0), lb: Double(payloadWeightLEO?.lb ?? 0))
        self.flickrImages = model.flickrImages.compactMap { URL(string: $0) }
        self.firstFlight = model.firstFlight
        self.countryID = model.country.getCountryCode() ?? model.country
        self.costPerLaunch = model.costPerLaunch
        self.firstStageEngines = model.firstStage.engines
        self.firstStageFuelAmountTons = model.firstStage.fuelAmountTons
        self.firstStageBurnTimeSEC = model.firstStage.burnTimeSec ?? 0
        self.secondStageEngines = model.secondStage.engines
        self.secondStageFuelAmountTons = model.secondStage.fuelAmountTons
        self.secondStageBurnTimeSEC = model.secondStage.burnTimeSec ?? 0
    }
}

struct Rocket: ReducerProtocol {
    struct State: Equatable, Identifiable  {
        var id: String
        var name: String
        var height: Length
        var diameter: Length
        var mass: Weight
        var payloadWeights: Weight
        var flickrImages: [URL]
        
        var firstFlight: Date
        var countryID: String
        var costPerLaunch: Int
        
        var firstStageEngines: Int
        var firstStageFuelAmountTons: Double
        var firstStageBurnTimeSEC: Int
        
        var secondStageEngines: Int
        var secondStageFuelAmountTons: Double
        var secondStageBurnTimeSEC: Int
        
        var launchList: LaunchList.State?
        var settings: Settings.State = .init()
        var imageLoader: ImageLoader.State?
        var showLaunches: Bool = false
        var showSettings: Bool = false
    }
    
    enum Action: Equatable {
        case onAppear
        case loadSettings
        case launchList(LaunchList.Action)
        case settings(Settings.Action)
        case imageLoader(ImageLoader.Action)
        case showLaunchesTapped(show: Bool)
        case showSettingsTapped(show: Bool)
    }
    
    @Dependency(\.userDefaults) var userDefaults
    
    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.settings, action: /Action.settings) {
            Settings()
        }
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                if let url = state.flickrImages.randomElement() {
                    state.imageLoader = .init(url: url)
                    
                    return .run { send in
                        await send(.imageLoader(.load))
                    }
                }
                return .none
            case .loadSettings:
                state.height.type = userDefaults.heinghtValueType
                state.diameter.type = userDefaults.diameterValueType
                state.mass.type = userDefaults.massValueType
                state.payloadWeights.type = userDefaults.payloadWeightsValueType
                return .none
            case .launchList(_):
                return .none
            case .settings(.closeButtonTapped):
                return .run { send in
                    await send(.showSettingsTapped(show: false))
                }
            case .settings(_):
                return .none
            case .imageLoader(_):
                return .none
            case .showLaunchesTapped(let show):
                if show {
                    state.launchList = .init(rocketID: state.id, rocketName: state.name)
                }
                state.showLaunches = show
                return .none
            case .showSettingsTapped(let show):
                state.showSettings = show
                return .none
            }
        }
        .ifLet(\.launchList, action: /Action.launchList) {
            LaunchList()
        }
        .ifLet(\.imageLoader, action: /Action.imageLoader) {
            ImageLoader()
        }
    }
}

struct RocketView: View {
    let store: StoreOf<Rocket>
    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack(spacing: 0) {
                Spacer(minLength: 200)
                VStack(spacing: 10){
                    HStack {
                        Text(viewStore.name)
                        Spacer()
                        Button(action: { viewStore.send(.showSettingsTapped(show: true)) }, label: {
                            Image(systemName: "gearshape")
                                .background{
                                    Rectangle().frame(width: 70, height: 70).opacity(0.001) //Increase tap area
                                }
                        })
                        .accessibilityIdentifier("button.settings.id")
                        .buttonStyle(PlainButtonStyle())
                    }
                    .font(.title)
                    .padding(.vertical, 30)
                    .padding(.horizontal, 20)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            BoxedInfoView(name: Localazed.height, value: viewStore.height)
                            BoxedInfoView(name: Localazed.diameter, value: viewStore.diameter)
                            BoxedInfoView(name: Localazed.mass, value: viewStore.mass)
                            BoxedInfoView(name: Localazed.payload_weight, value: viewStore.payloadWeights)
                        }
                        .padding(.horizontal, 20)
                    }
                    .accessibilityIdentifier("scroll.info.id")
                    Group {
                        VStack(alignment: .leading, spacing: 10) {
                            RowInfoView(name: Localazed.first_flight, value: viewStore.firstFlight.getFormatedDateText)
                            RowInfoView(name: Localazed.country, value: "\(viewStore.countryID)")
                            RowInfoView(name: Localazed.cost_per_launch, value: String(format: "$%.1f", Double(viewStore.costPerLaunch / 1000000)), type: Localazed.mil)
                        }
                        .padding(.vertical, 10)
                        
                        StageView(
                            title: Localazed.first_stage.uppercased(),
                            engines: viewStore.firstStageEngines,
                            fuelAmountTons: viewStore.firstStageFuelAmountTons,
                            burnTimeSEC: viewStore.firstStageBurnTimeSEC
                        )
                        .padding(.vertical, 10)
                        
                        StageView(
                            title: Localazed.second_stage.uppercased(),
                            engines: viewStore.secondStageEngines,
                            fuelAmountTons: viewStore.secondStageFuelAmountTons,
                            burnTimeSEC: viewStore.secondStageBurnTimeSEC
                        )
                        .padding(.vertical, 10)
                        
                        Button(action: { viewStore.send(.showLaunchesTapped(show: true)) }, label: {
                            Text(Localazed.show_launches)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.itemBackground)
                                )
                        })
                        .buttonStyle(PlainButtonStyle())
                        .frame(minHeight: 70)
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 50)
                }
                .background (
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .fill(Color.background)
                )
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
            .sheet(isPresented: viewStore.binding(get: \.showSettings, send: Rocket.Action.showSettingsTapped), onDismiss: { viewStore.send(.showSettingsTapped(show: false)) }) {
                SettingsView(store: store.scope(state: \.settings, action: Rocket.Action.settings))
            }
            .background(
                NavigationLink(
                    destination: IfLetStore(
                        self.store.scope(
                            state: \.launchList,
                            action: Rocket.Action.launchList
                        )
                    ) { launchListStroe in
                        LaunchListView(store: launchListStroe)
                    },
                    isActive: viewStore.binding(
                        get: \.showLaunches,
                        send: Rocket.Action.showLaunchesTapped(show:)
                    )
                    
                )
                { EmptyView()}
                    .disabled(!viewStore.showLaunches)
            )
        }
    }
}

struct RocketImageView: View {
    let store: StoreOf<Rocket>
    var body: some View {
        WithViewStore(self.store) { viewStore in
            if viewStore.imageLoader != nil {
                IfLetStore(
                    self.store.scope(
                        state: \.imageLoader,
                        action: Rocket.Action.imageLoader
                    )
                ) { imageLoaderStore in
                    ImageLoaderView(store: imageLoaderStore)
                }
            } else {
                Rectangle()
                    .fill(Color.itemBackground)
            }
        }
    }
}

private struct StageView: View {
    let title: String
    var engines: Int
    var fuelAmountTons: Double
    var burnTimeSEC: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.title3)
                .padding(.vertical, 10)
            RowInfoView(name: Localazed.number_of_engines, value: "\(engines)", type: " ")
            RowInfoView(name: Localazed.fuel_quantity, value: "\(fuelAmountTons)", type: Localazed.ton)
            RowInfoView(name: Localazed.burn_time, value: "\(burnTimeSEC)", type: Localazed.sec)
        }
    }
}

private struct BoxedInfoView: View {
    let name: String
    let value: DoubleValue
    
    var body: some View {
        VStack {
            Text(String(format: "%.1f", value.val))
            Text("\(name), \(value.typeName)")
                .foregroundColor(.gray)
        }
        .frame(width: 120, height: 120)
        .background(
            RoundedRectangle(cornerRadius: 35)
                .fill(Color.itemBackground)
        )
    }
}

private struct RowInfoView: View {
    let name: String
    let value: String
    let type: String
    
    init(name: String, value: String, type: String = "") {
        self.name = name
        self.value = value
        self.type = type
    }
        
    var body: some View {
        HStack {
            Text(name)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
            if type.isEmpty == false {
                Text(type)
                    .foregroundColor(.gray)
                    .frame(minWidth: 30)
            }
        }
    }
}


struct RocketView_Previews: PreviewProvider {
    static let rocket: Rocket.State = .init(
        id: "5e9d012345678901234567890",
        name: "Rocket Name",
        height: .init(m: 100, ft: 300),
        diameter: .init(m: 5, ft: 15),
        mass: .init(kg: 12000, lb: 24000),
        payloadWeights: .init(kg: 4000, lb: 8000),
        flickrImages: [],
        firstFlight: Date(),
        countryID: "US",
        costPerLaunch: 1000000,
        firstStageEngines: 8,
        firstStageFuelAmountTons: 9,
        firstStageBurnTimeSEC: 500,
        secondStageEngines: 5,
        secondStageFuelAmountTons: 2,
        secondStageBurnTimeSEC: 120
    )
   
    static var previews: some View {
        RocketView(store: Store(
                initialState: rocket,
                reducer: Rocket()
            )
        )
    }
}
