import Foundation
import Dependencies


struct SpaceXClient {
    var getRockets: @Sendable () async throws -> [RocketAPIModel.Mini]
    var getLaunchesAll: @Sendable () async throws -> [LaunchAPIModel.Mini]
    var getLaunchesFor: @Sendable (_ rocketId: String) async throws -> [LaunchAPIModel.Mini]
    
    enum Failure: Error {
        case ResponseError
    }
}
extension DependencyValues {
  var spacexClient: SpaceXClient {
    get { self[SpaceXClient.self] }
    set { self[SpaceXClient.self] = newValue }
  }
}
