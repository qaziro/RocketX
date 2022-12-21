import Foundation
import SwiftUI

extension Date{
    var getFormatedDateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM, yyyy"
        return formatter.string(from: self)
    }
}

extension String {
    func getCountryCode() -> String? {
        for localeCode in NSLocale.isoCountryCodes {
            let usLocale = NSLocale(localeIdentifier: "en_US")
            let countryName = usLocale.displayName(forKey: NSLocale.Key.countryCode, value: localeCode) ?? ""
            if self.lowercased().contains(countryName.lowercased()) {
                return localeCode
            }
        }
        return nil
    }
}
