

import UIKit

class TiltShiftTableViewController: UITableViewController {
  private let queue = OperationQueue()
  private var urls: [URL] = []
  private var operations: [IndexPath: [Operation]] = [:]

  override func viewDidLoad() {
    super.viewDidLoad()

    guard let plist = Bundle.main.url(forResource: "Photos", withExtension: "plist"),
          let contents = try? Data(contentsOf: plist),
          let serial = try? PropertyListSerialization.propertyList(from: contents, format: nil),
          let serialUrls = serial as? [String] else {
      print("Something went horribly wrong!")
      return
    }

    urls = serialUrls.compactMap { URL(string: $0) }
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return urls.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "normal", for: indexPath) as! PhotoCell
    cell.display(image: nil)
    
    let downloadOp = NetworkImageOperation(url: urls[indexPath.row])
    let tiltShiftOp = TiltShiftOperation()
    tiltShiftOp.addDependency(downloadOp)

    tiltShiftOp.onImageProcessed = { image in
      guard let cell = tableView.cellForRow(at: indexPath)
        as? PhotoCell else {
          return
      }
      
      cell.isLoading = false
      cell.display(image: image)
    }

    queue.addOperation(downloadOp)
    queue.addOperation(tiltShiftOp)

    if let existingOperations = operations[indexPath] {
      for operation in existingOperations {
        operation.cancel()
      }
    }

    operations[indexPath] = [tiltShiftOp, downloadOp]

    return cell
  }

  override func tableView(
    _ tableView: UITableView,
    didEndDisplaying cell: UITableViewCell,
    forRowAt indexPath: IndexPath) {

    if let operations = operations[indexPath] {
      for operation in operations {
        operation.cancel()
      }
    }
  }
}
