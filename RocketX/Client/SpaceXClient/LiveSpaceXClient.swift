import Foundation
import ComposableArchitecture

extension SpaceXClient: DependencyKey {
    static var liveValue: Self = {
        let decoder: JSONDecoder = .customDecoder
        
        return Self(
            getRockets: {
                let url = URL(string: "https://api.spacexdata.com/v4/rockets")!
                let (data, _) = try await URLSession.shared.data(from: url)
                return try decoder.decode([RocketAPIModel.Mini].self, from: data)
            },
            getLaunchesAll: {
                let url = URL(string: "https://api.spacexdata.com/v4/launches")!
                let (data, _) = try await URLSession.shared.data(from: url)
                return try decoder.decode([LaunchAPIModel.Mini].self, from: data)
            },
            getLaunchesFor: { rocketId in
                let url = URL(string: "https://api.spacexdata.com/v4/launches/query")!
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue("application/json", forHTTPHeaderField: "Accept")
                
                let parameters: [String: Any] = [
                    "query": [
                        "rocket": rocketId
                    ],
                    "options": [
                        "pagination": false,
                        "limit": 100,
                        "sort": [
                           "date_utc": "desc"
                        ]
                    ]
                ]
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
               
                return try await withCheckedThrowingContinuation { continuation in
                    URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
                        if let data = data {
                            do {
                                let responseObject = try decoder.decode(LaunchAPIQueryModel.Mini.self, from: data)
                                continuation.resume(returning: responseObject.docs)
                            }catch {
                                continuation.resume(throwing: error)
                            }
                            return
                        }
                        continuation.resume(throwing: SpaceXClient.Failure.ResponseError)
                    }.resume()
                }
            }
        )
    }()
}

private extension JSONDecoder {
    static var customDecoder: JSONDecoder {
        let formatter = DateFormatter()

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            formatter.dateFormat = "yyyy-MM-dd" // "first_flight":"2006-03-24"
            if let date = formatter.date(from: dateString) {
                return date
            }
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ" // "date_local":"2009-07-13T15:35:00+12:00"
            if let date = formatter.date(from: dateString) {
                return date
            }
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'" // "date_utc":"2008-09-28T23:15:00.000Z"
            if let date = formatter.date(from: dateString) {
                return date
            }
            throw DecodingError.dataCorruptedError(in: container,
                                                   debugDescription: "Cannot decode date string \(dateString)")
        }
        return decoder
    }
}
