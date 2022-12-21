//
// https://www.donnywals.com/using-swifts-async-await-to-build-an-image-loader/
// modified to use NSCache
//

import UIKit

actor ImageLoaderActor {
    private var images: [URLRequest: LoaderStatus] = [:]
    private var cache: ImageCache?

    init(cache: ImageCache? = nil) {
        self.cache = cache
    }
    
    public func fetch(_ url: URL) async throws -> UIImage {
        let request = URLRequest(url: url)
        return try await fetch(request)
    }

    public func fetch(_ urlRequest: URLRequest) async throws -> UIImage {
        guard let url = urlRequest.url else {
            throw ImageLoaderError.badURL(urlRequest)
        }
        
        if let image = cache?[url] {
            return image
        }
        
        if let status = images[urlRequest] {
            switch status {
            case .inProgress(let task):
                return try await task.value
            }
        }

        if let image = try self.imageFromFileSystem(for: urlRequest) {
            cache?[url] = image
            return image
        }

        let task: Task<UIImage, Error> = Task {
            let (imageData, _) = try await URLSession.shared.data(for: urlRequest)
            let image = UIImage(data: imageData)!
            try self.persistImage(image, for: urlRequest)
            return image
        }

        images[urlRequest] = .inProgress(task)

        let image = try await task.value
        
        cache?[url] = image

        return image
    }
    
    private func imageFromFileSystem(for urlRequest: URLRequest) throws -> UIImage? {
        guard let url = fileName(for: urlRequest) else {
            assertionFailure("Unable to generate a local path for \(urlRequest)")
            return nil
        }
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        let data = try Data(contentsOf: url)
        return UIImage(data: data)
    }

    private func fileName(for urlRequest: URLRequest) -> URL? {
        guard let fileName = urlRequest.url?.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
              let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
                  return nil
              }
        return cachesDirectory.appendingPathComponent(fileName)
    }
    
    private func persistImage(_ image: UIImage, for urlRequest: URLRequest) throws {
        guard let url = fileName(for: urlRequest),
              let data = image.jpegData(compressionQuality: 0.8) else {
            assertionFailure("Unable to generate a local path for \(urlRequest)")
            return
        }

        try data.write(to: url)
    }

    enum LoaderStatus {
        case inProgress(Task<UIImage, Error>)
    }
    
    enum ImageLoaderError: Error {
        case badURL(URLRequest)
    }
}
