import XCTestDynamicOverlay
import Dependencies
import Foundation

extension SpaceXClient: TestDependencyKey {
    static let testValue = Self(
        getRockets: { return SpaceXTestHelper.rockets },
        getLaunchesAll: { return SpaceXTestHelper.launches },
        getLaunchesFor: { _ in  return SpaceXTestHelper.launches }
    )
}

struct SpaceXTestHelper {
    static var rockets: [RocketAPIModel.Mini] = {
        var result: [RocketAPIModel.Mini] = []
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        
        let date1 = formatter.date(from: "2020/01/01 00:01")!
        let date2 = formatter.date(from: "2020/02/02 00:02")!
        
        let r1: RocketAPIModel.Mini = .init(
            id: "0123456789",
            name: "Rocket01",
            height: .init(meters: 100, feet: 300),
            diameter: .init(meters: 5, feet: 15),
            mass: .init(kg: 1000, lb: 2000),
            payloadWeights: [.init(id: "leo", name: "001", kg: 1000, lb: 2000)],
            flickrImages: ["https://farm5.staticflickr.com/4599/38583829295_581f34dd84_b.jpg","https://farm5.staticflickr.com/4645/38583830575_3f0f7215e6_b.jpg"],
            firstFlight: date1,
            country: "United States",
            costPerLaunch: 10000000,
            firstStage: .init(engines: 3, fuelAmountTons: 6, burnTimeSec: 30),
            secondStage: .init(engines: 1, fuelAmountTons: 3, burnTimeSec: 10)
        )
        let r2: RocketAPIModel.Mini = .init(
            id: "9876543210",
            name: "Rocket02",
            height: .init(meters: 200, feet: 600),
            diameter: .init(meters: 7, feet: 21),
            mass: .init(kg: 1500, lb: 3000),
            payloadWeights: [.init(id: "leo", name: "002", kg: 2000, lb: 4000)],
            flickrImages: ["https://farm4.staticflickr.com/3955/32915197674_eee74d81bb_b.jpg","https://farm1.staticflickr.com/293/32312415025_6841e30bf1_b.jpg"],
            firstFlight: date2,
            country: "United States",
            costPerLaunch: 20000000,
            firstStage: .init(engines: 5, fuelAmountTons: 10, burnTimeSec: 40),
            secondStage: .init(engines: 2, fuelAmountTons: 4, burnTimeSec: 20)
        )
        result.append(r1)
        result.append(r2)
        return result
    }()
    
    static var launches: [LaunchAPIModel.Mini] = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        
        let date1 = formatter.date(from: "2020/01/01 00:01")!
        let date2 = formatter.date(from: "2020/02/02 00:02")!
        let date3 = formatter.date(from: "2020/03/03 00:03")!
        
        let l1: LaunchAPIModel.Mini = .init(id: "01", name: "Launch01", dateLocal: date1, success: nil)
        let l2: LaunchAPIModel.Mini = .init(id: "02", name: "Launch02", dateLocal: date2, success: false)
        let l3: LaunchAPIModel.Mini = .init(id: "03", name: "Launch03", dateLocal: date3, success: true)
        return [l1, l2, l3]
    }()
}
