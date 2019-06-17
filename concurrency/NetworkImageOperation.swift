

import UIKit

final class NetworkImageOperation: AsyncOperation {
  var image: UIImage?

  private let url: URL
  private let completionHandler: ((Data?, URLResponse?, Error?) -> Void)?
  private var task: URLSessionDataTask?

  init(url: URL, completionHandler: ((Data?, URLResponse?, Error?) -> Void)? = nil) {
    self.url = url
    self.completionHandler = completionHandler

    super.init()
  }

  convenience init?(string: String, completionHandler: ((Data?, URLResponse?, Error?) -> Void)? = nil) {
    guard let url = URL(string: string) else { return nil }
    self.init(url: url, completionHandler: completionHandler)
  }

  override func main() {
    task = URLSession.shared.dataTask(with: url) { [weak self]
      data, response, error in

      guard let self = self else { return }

      defer { self.state = .finished }

      guard !self.isCancelled else { return }

      if let completionHandler = self.completionHandler {
        completionHandler(data, response, error)
        return
      }

      guard error == nil, let data = data else { return }

      self.image = UIImage(data: data)
    }

    task?.resume()
  }

  override func cancel() {
    super.cancel()
    task?.cancel()
  }
}

extension NetworkImageOperation: ImageDataProvider {}
