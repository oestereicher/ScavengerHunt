/// Copyright (c) 2021 Razeware LLC
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

import MapKit
import Foundation
import UIKit

class PinAnnotation : MKPointAnnotation {
  private var _coordinate: CLLocationCoordinate2D
  
  private var _location: Location
  private var _title: String = String("")
  private var _subtitle: String = String("")
  private var _unlocked: Bool = false
  
  var pinTintColor: UIColor?
  
  override var coordinate: CLLocationCoordinate2D {
    get {
      return _coordinate
    }
    set(value) {
      self._coordinate = value
    }
  }
  
  var location: Location {
    get {
      return _location
    }
  }
  
  override var title: String? {
    get {
      return _title
    }
    set(value) {
      self._title = value!
    }
  }
  
  override var subtitle: String? {
    get {
      return _subtitle
    }
    set(value) {
      self._subtitle = value!
    }
  }
  
  var unlocked: Bool {
    get {
      return _unlocked
    }
  }
  
  init(location: Location) {
    self._location = location
    self._coordinate = location.coordinates
  }
  
  func checkPassword(attempt: String) -> Bool {
    return attempt == self.location.password
  }
}
