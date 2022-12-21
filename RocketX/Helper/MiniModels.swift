import Foundation

public enum WeightType: String {
    case kg = "kg"
    case lb = "lb"
}

public enum LengthType: String {
    case m = "m"
    case ft = "ft"
}

struct Weight: Equatable, DoubleValue {
    let kg: Double
    let lb: Double
    var type: WeightType = .kg    
   
    var val: Double {
        return type == .kg ? kg : lb
    }
    
    var typeName: String {
        return type == .kg ? Localazed.kg : Localazed.lb
    }
}

struct Length: Equatable, DoubleValue {
    let m: Double
    let ft: Double
    var type: LengthType = .m
    
    var val: Double {
        return type == .m ? m : ft
    }
    
    var typeName: String {
        return type == .m ? Localazed.m : Localazed.ft
    }
}

protocol DoubleValue {
    var val: Double { get }
    var typeName: String { get }
}
