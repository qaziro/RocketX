//
//  Generated by https://app.quicktype.io/
//

import Foundation

extension LaunchAPIQueryModel {
    struct Mini: Codable {
        let docs: [LaunchAPIModel.Mini]
    }
}

extension LaunchAPIModel {
    struct Mini: Codable, Equatable {
        let id: String
        let name: String
        let dateLocal: Date
        let success: Bool?
    }
}

struct LaunchAPIQueryModel: Codable {
    let docs: [LaunchAPIModel]
    let totalDocs: Int
    let offset: Int
    let limit: Int
    let totalPages: Int
    let page: Int
    let pagingCounter: Int
    let hasPrevPage: Bool
    let hasNextPage: Bool
    let prevPage: Int?
    let nextPage: Int?
}

struct LaunchAPIModel: Codable {
    let fairings: Fairings?
    let links: Links
    let staticFireDateUtc: Date?
    let staticFireDateUnix: Int?
    let net: Bool
    let window: Int?
    let rocket: String
    let success: Bool?
    let failures: [Failure]
    let details: String?
    let crew: [String]
    let ships: [String]
    let capsules: [String]
    let payloads: [String]
    let launchpad: String
    let flightNumber: Int
    let name: String
    let dateUtc: Date
    let dateUnix: Int
    let dateLocal: Date
    let datePrecision: DatePrecision
    let upcoming: Bool
    let cores: [Core]
    let autoUpdate: Bool
    let tbd: Bool
    let launchLibraryID: String?
    let id: String
    
    // MARK: - Core
    struct Core: Codable {
        let core: String?
        let flight: Int?
        let gridfins: Bool?
        let legs: Bool?
        let reused: Bool?
        let landingAttempt: Bool?
        let landingSuccess: Bool?
        let landingType: LandingType?
        let landpad: String?
    }

    // MARK: - Failure
    struct Failure: Codable {
        let time: Int
        let altitude: Int?
        let reason: String
    }

    // MARK: - Fairings
    struct Fairings: Codable {
        let reused: Bool?
        let recoveryAttempt: Bool?
        let recovered: Bool?
        let ships: [String]
    }

    // MARK: - Links
    struct Links: Codable {
        let patch: Patch
        let reddit: Reddit
        let flickr: Flickr
        let presskit: String?
        let webcast: String?
        let youtubeID: String?
        let article: String?
        let wikipedia: String?
    }

    // MARK: - Flickr
    struct Flickr: Codable {
        let small: [String]
        let original: [String]
    }

    // MARK: - Patch
    struct Patch: Codable {
        let small: String?
        let large: String?
    }

    // MARK: - Reddit
    struct Reddit: Codable {
        let campaign: String?
        let launch: String?
        let media: String?
        let recovery: String?
    }
 
    enum DatePrecision: String, Codable {
        case day = "day"
        case hour = "hour"
        case month = "month"
    }
    
    enum LandingType: String, Codable {
        case asds = "ASDS"
        case ocean = "Ocean"
        case rtls = "RTLS"
    }
}

