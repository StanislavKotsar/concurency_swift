

import UIKit

final class PhotoCell: UITableViewCell {
  @IBOutlet private weak var nasaImageView: UIImageView!
  @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

  var isLoading: Bool {
    get { return activityIndicator.isAnimating }
    set {
      if newValue {
        activityIndicator.startAnimating()
      } else {
        activityIndicator.stopAnimating()
      }
    }
  }

  func display(image: UIImage?) {
    nasaImageView.image = image
  }
}

