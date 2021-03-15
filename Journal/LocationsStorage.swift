/// Copyright (c) 2018 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation
import CoreLocation

class LocationsStorage {
  static let shared = LocationsStorage()
  
  private(set) var locations: [Location]
  private let fileManager: FileManager
  private let documentsURL: URL
  
  init() {
    let fileManager = FileManager.default
    documentsURL = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)    
    self.fileManager = fileManager
    let jsonDecoder = JSONDecoder()

    // 1
    let locationFilesURLs = try! fileManager
      .contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
    locations = locationFilesURLs.compactMap { url -> Location? in
      // 2
      guard !url.absoluteString.contains(".DS_Store") else {
        return nil
      }
      // 3
      guard let data = try? Data(contentsOf: url) else {
        return nil
      }
      // 4
      return try? jsonDecoder.decode(Location.self, from: data)
      // 5
      }.sorted(by: { $0.date < $1.date })

  }
  
  func saveLocationOnDisk(_ location: Location) {
    // 1
    let encoder = JSONEncoder()
    let timestamp = location.date.timeIntervalSince1970

    // 2
    let fileURL = documentsURL.appendingPathComponent("\(timestamp)")

    // 3
    let data = try! encoder.encode(location)

    // 4
    try! data.write(to: fileURL)

    // 5
    locations.append(location)
  }
  
  func saveCLLocationToDisk(_ clLocation: CLLocation, unlocked: Bool, password: String, clueImage: String) {
    let currentDate = Date()
    AppDelegate.geoCoder.reverseGeocodeLocation(clLocation) { placemarks, _ in
      if let place = placemarks?.first {
        let location = Location(clLocation.coordinate, date: currentDate, descriptionString: "\(place)", unlocked: unlocked, password: password, clueImage: clueImage)
        self.saveLocationOnDisk(location)
      }
    }
  }
  
  func unlockLocation(index: Int) {
    locations[index].unlocked = true
    let location = locations[index]
    
    // update the stored location
//    let decoder = JSONDecoder()
    
    let timestamp = locations[index].date.timeIntervalSince1970
    let fileURL = documentsURL.appendingPathComponent("\(timestamp)")
//    let data = try! Data(contentsOf: fileURL)
//    print(data.base64EncodedString())
//    let decoded = try! decoder.decode(Location.self, from: data)
    
    let encoder = JSONEncoder()
    let dataToSave = try! encoder.encode(Location(location.coordinates, date: location.date, descriptionString: location.description, unlocked: true, password: location.password, clueImage: location.clueImage))
    try! dataToSave.write(to: fileURL)
    
    NotificationCenter.default.post(name: .newLocationSaved, object: self, userInfo: ["location": location])

  }
  
  func numUnlocked() -> Int {
    var count = 0
    for location in locations {
      if location.unlocked {
        count += 1
      }
    }
    return count
  }
}

extension Notification.Name {
  static let newLocationSaved = Notification.Name("newLocationSaved")
}
