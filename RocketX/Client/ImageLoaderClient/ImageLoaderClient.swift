import Foundation
import Dependencies
import XCTestDynamicOverlay
import UIKit

struct ImageLoaderClient {
    var load: @Sendable (_ url: URL) async throws -> UIImage
}

extension ImageLoaderClient: TestDependencyKey {
    static let testValue = Self(
        load: XCTUnimplemented("\(Self.self).load")
    )
}

extension DependencyValues {
  var imageLoader: ImageLoaderClient {
    get { self[ImageLoaderClient.self] }
    set { self[ImageLoaderClient.self] = newValue }
  }
}
