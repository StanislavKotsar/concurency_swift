

import UIKit

final class TiltShiftOperation: Operation {
  private static let context = CIContext()
  
  /// Callback which will be run *on the main thread*
  /// when the operation completes.
  var onImageProcessed: ((UIImage?) -> Void)?

  var outputImage: UIImage?

  private let inputImage: UIImage?

  init(image: UIImage? = nil) {
    inputImage = image
    super.init()
  }

  override func main() {
    var imageToProcess: UIImage
    
    if let inputImage = inputImage {
      // 1
      imageToProcess = inputImage
    } else {
      // 2
      let dependencyImage: UIImage? = dependencies
        .compactMap { ($0 as? ImageDataProvider)?.image }
        .first
      
      if let dependencyImage = dependencyImage {
        imageToProcess = dependencyImage
      } else {
        // 3
        return
      }
    }

    guard let filter = TiltShiftFilter(image: imageToProcess, radius: 3),
      let output = filter.outputImage else {
        print("Failed to generate tilt shift image")
        return
    }

    guard !isCancelled else { return }
    let fromRect = CGRect(origin: .zero, size: imageToProcess.size)
    guard
      let cgImage = TiltShiftOperation.context.createCGImage(output, from: fromRect),
      let rendered = cgImage.rendered()
    else {
      print("No image generated")
      return
    }

    guard !isCancelled else { return }
    outputImage = UIImage(cgImage: rendered)
    
    if let onImageProcessed = onImageProcessed {
      DispatchQueue.main.async { [weak self] in
        onImageProcessed(self?.outputImage)
      }
    }
  }
}

extension TiltShiftOperation: ImageDataProvider {
  var image: UIImage? { return outputImage }
}
