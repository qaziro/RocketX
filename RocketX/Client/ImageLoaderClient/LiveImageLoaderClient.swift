import Foundation
import ComposableArchitecture
import CoreGraphics

extension ImageLoaderClient: DependencyKey {
    static var liveValue: Self = {
        let cache = TemporaryImageCache()
        let loader = ImageLoaderActor(cache: cache)
        return Self(
            load: { url in
                return try await loader.fetch(url)
            }
        )
    }()
}

