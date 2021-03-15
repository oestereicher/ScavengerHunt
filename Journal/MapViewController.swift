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

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
  @IBOutlet weak var mapView: MKMapView!
  
  
//  let annotation = PinAnnotation()
  
  override func viewDidLoad() {
    mapView.delegate = self
    super.viewDidLoad()
    mapView.userTrackingMode = .follow
    for (index, location) in LocationsStorage.shared.locations.enumerated() {
      if location.unlocked {
        let annotation = PinAnnotation(location: location)
//        if index == UserDefaults.standard.value(forKey: "maxIndexUnlocked") as! Int {
//          annotation.pinColor = .green
//        }
        if index == UserDefaults.standard.value(forKey: "maxUnlockedIndex") as! Int {
          annotation.pinTintColor = .red
        }
        else {
          annotation.pinTintColor = .green
        }
        mapView.addAnnotation(annotation)
      }
    }
    
    navigationItem.leftBarButtonItem =  UIBarButtonItem.init(title: "Clear Directions", style: .plain, target: self, action: #selector(self.clearDirectionsClicked))
//    annotation.setCoordinate(newCoordinate: CLLocationCoordinate2D(latitude: 43.069556, longitude: -89.438949))
//    annotation.title = "The location"
//    annotation.subtitle = "yes it is here"
//    mapView.addAnnotation(annotation)
  }
  
  @IBAction func addItemPressed(_ sender: Any) {
    guard let currentLocation = mapView.userLocation.location else {
      return
    }

    LocationsStorage.shared.saveCLLocationToDisk(currentLocation, unlocked: true, password: "password", clueImage: "sample.jpg")

  }
  
  @objc func clearDirectionsClicked() {
    let overlays = mapView.overlays
    mapView.removeOverlays(overlays)
  }
  
  func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//    let newAnnotation = MKPointAnnotation()
//    newAnnotation.coordinate = CLLocationCoordinate2D(latitude: 43.072556, longitude: -89.426949)
//    newAnnotation.title = view.annotation?.title ?? "whatt"
//    mapView.addAnnotation(newAnnotation)
    
//    var popUpWindow: PopUpWindow!
//    popUpWindow = PopUpWindow(title: "Error", text: "ope", buttontext: "OK")
//    self.present(popUpWindow, animated: true, completion: nil)
    if let pin = view.annotation as? PinAnnotation {
      let passwordAlert: UIAlertController
      
      let index = pin.location.getIndex()
      if index >= UserDefaults.standard.value(forKey: "maxUnlockedIndex") as! Int {
        passwordAlert = UIAlertController(title: "Password", message: "Password for \(pin.location.description)", preferredStyle: .alert)
      }
      else {
        passwordAlert = UIAlertController(title: "\(pin.location.description)", message: "", preferredStyle: .alert)
      }
      
      
      
      let submitAction = UIAlertAction(title: "Submit", style: .default) { Void in
        let textField = passwordAlert.textFields![0] as UITextField
        
        let dismissAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        if pin.checkPassword(attempt: textField.text!) { // correct password
          // mark unlocked pin as green
          UserDefaults.standard.setValue(UserDefaults.standard.value(forKey: "maxUnlockedIndex") as! Int + 1, forKey: "maxUnlockedIndex")
          for annotation in self.mapView.annotations {
            guard let pinAnnotation = annotation as? PinAnnotation else {
              continue
            }
            if pinAnnotation.pinTintColor == .red {
              pinAnnotation.pinTintColor = .green
              mapView.removeAnnotation(annotation)
              mapView.addAnnotation(pinAnnotation)
            }
          }
          
          
          if index < LocationsStorage.shared.locations.count - 1 { // there are pins still left to unlock
            let nextIndex = index + 1
            LocationsStorage.shared.unlockLocation(index: nextIndex)
            let nextAnnotation = PinAnnotation(location: LocationsStorage.shared.locations[nextIndex])
            nextAnnotation.pinTintColor = .red
            mapView.addAnnotation(nextAnnotation)
            
            // show user that they were correct
            let correctAlert = UIAlertController(title: "Correct Password!", message: "Good job, you've unlocked the next clue", preferredStyle: .alert)
            correctAlert.addAction(dismissAction)
            self.present(correctAlert, animated: true, completion: nil)
          }
          else { // congrats you finished!
            let finishedAlert = UIAlertController(title: "Congratulations!!!", message: "You've successfully completed the scavenger hunt! Good Job!", preferredStyle: .alert)
            finishedAlert.addAction(dismissAction)
            self.present(finishedAlert, animated: true, completion: nil)
          }
        }
        else { // wrong password
          let incorrectAlert = UIAlertController(title: "Incorrect Password", message: "Please try again", preferredStyle: .alert)
          incorrectAlert.addAction(dismissAction)
          self.present(incorrectAlert, animated: true, completion: nil)
        }
      }
      
      let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
      
      let directionsAction = UIAlertAction(title: "Directions", style: .default) { Void in
        let request = MKDirections.Request()
        let currentLocation = mapView.userLocation.location
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: currentLocation!.coordinate))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: pin.location.coordinates))
        request.transportType = .walking
        
        let directions = MKDirections(request: request)
        directions.calculate { [unowned self] response, error in
          guard let unwrappedResponse = response else { return }
          
          for route in unwrappedResponse.routes {
            self.mapView.addOverlay(route.polyline)
            self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
          }
        }
      }
      
      passwordAlert.addAction(cancelAction)
      passwordAlert.addAction(directionsAction)
      
      if index >= UserDefaults.standard.value(forKey: "maxUnlockedIndex") as! Int {
        passwordAlert.addTextField { (textField: UITextField) in
          textField.placeholder = "Password"
        }
        passwordAlert.addAction((submitAction))
      }
      
      self.present(passwordAlert, animated: true, completion: nil)
    }
//    let passwordAlert = UIAlertController(title: "Password", message: "If you've found it, what's the password?", preferredStyle: .alert)
//    let submitAction = UIAlertAction(title: "Submit", style: .default) { Void in
//      let textField = passwordAlert.textFields![0] as UITextField
//      if textField.text == "hihihi" {
//        print("yay you did it")
//      }
//      else {
//        print("boo you suck")
//      }
//    }
//    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    
//    let imgViewTitle = UIImageView(frame: CGRect(x: 10, y: 10, width: 100, height: 100))
//    imgViewTitle.image = UIImage(named: "sample.jpg")
    
//    passwordAlert.view.addSubview(imgViewTitle)
//    passwordAlert.addTextField { (textField: UITextField) in
//      textField.placeholder = "Password"
//    }
//    passwordAlert.addAction(cancelAction)
//    passwordAlert.addAction(submitAction)
//    self.present(passwordAlert, animated: true, completion: nil)
  }
  
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
    renderer.strokeColor = UIColor(red: 0/255, green: 104/255, blue: 55/255, alpha: 1)
    return renderer
  }
  
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    // Don't change how user's location is displayed
    if !annotation.isEqual(mapView.userLocation) {
      var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "myAnnotation") as? MKPinAnnotationView
      if annotationView == nil {
        annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "myAnnotation")
      }
      else {
        annotationView?.annotation = annotation
      }
      
      if let annotation = annotation as? PinAnnotation {
        annotationView?.pinTintColor = annotation.pinTintColor
      }
      
      return annotationView
    }
    else {
      return nil
    }
  }
}
