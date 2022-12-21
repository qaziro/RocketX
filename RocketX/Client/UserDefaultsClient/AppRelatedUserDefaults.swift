import Foundation

extension UserDefaultsClient {
    public var heinghtValueType: LengthType {
        LengthType(rawValue: self.stringForKey(settingsHeinghtKey) ?? "") ?? .m
    }
    
    public func setHeinghtValueType(_ type: LengthType) async {
        await self.setString(type.rawValue, settingsHeinghtKey)
    }
    
    public var diameterValueType: LengthType {
        LengthType(rawValue: self.stringForKey(settingsDiameterKey) ?? "") ?? .m
    }
    
    public func setDiameterValueType(_ type: LengthType) async {
        await self.setString(type.rawValue, settingsDiameterKey)
    }
    
    public var massValueType: WeightType {
        WeightType(rawValue: self.stringForKey(settingsMassKey) ?? "") ?? .kg
    }
    
    public func setMassValueType(_ type: WeightType) async {
        await self.setString(type.rawValue, settingsMassKey)
    }
    
    public var payloadWeightsValueType: WeightType {
        WeightType(rawValue: self.stringForKey(settingsPayloadWeightsKey) ?? "") ?? .kg
    }
    
    public func setPayloadWeightsValueType(_ type: WeightType) async {
        await self.setString(type.rawValue, settingsPayloadWeightsKey)
    }
}

private let settingsHeinghtKey = "settingsHeinghtKey"
private let settingsDiameterKey = "settingsDiameterKey"
private let settingsMassKey = "settingsMassKey"
private let settingsPayloadWeightsKey = "settingsPayloadWeightsKey"

