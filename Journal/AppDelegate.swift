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
import CoreLocation
import UserNotifications
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
  static let geoCoder = CLGeocoder()

  var window: UIWindow?
  
  let center = UNUserNotificationCenter.current()
  let locationManager = CLLocationManager()
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    let rayWenderlichColor = UIColor(red: 0/255, green: 104/255, blue: 55/255, alpha: 1)
    UITabBar.appearance().tintColor = rayWenderlichColor
    
    // request notification access
    center.requestAuthorization(options: [.alert, .sound]) { granted, error in
    }

    // request location access
    locationManager.requestAlwaysAuthorization()
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.startUpdatingLocation()
    locationManager.allowsBackgroundLocationUpdates = true
    locationManager.pausesLocationUpdatesAutomatically = false
    
    // save initial locations to disk
    let locations: [Location] = createLocations([
      SimpleLocation(latitude: 43.0648203, longitude: -89.4171795, clueName: "Crescendo", password: "coffee", clueImage: "clue1.heic"),
      SimpleLocation(latitude: 43.0631503, longitude: -89.4114308, clueName: "Bear Effigy", password: "midwest", clueImage: "clue2.heic"),
      SimpleLocation(latitude: 43.064516, longitude: -89.424196, clueName: "Jupiter", password: "URANUS", clueImage: "clue3.heic"),
      SimpleLocation(latitude: 43.0542955, longitude: -89.4506712, clueName: "Chocolate Shoppe", password: "icecream", clueImage: "clue4.heic"),
      SimpleLocation(latitude: 43.058687, longitude: -89.441793, clueName: "Jacobs House", password: "IOWA", clueImage: "clue5.heic"),
      SimpleLocation(latitude: 43.066, longitude: -89.440, clueName: "Reservoir Park", password: "patrick", clueImage: "clue6.heic"),
      SimpleLocation(latitude: 43.073450, longitude: -89.441536, clueName: "Quarry Park", password: "HAPPY", clueImage: "clue7.heic"),
      SimpleLocation(latitude: 43.0818307, longitude: -89.4468397, clueName: "Four Corners", password: "bday", clueImage: "clue8.heic"),
      SimpleLocation(latitude: 43.076109, longitude: -89.434733, clueName: "Unitarian", password: "urcute", clueImage: "clue9.heic"),
      SimpleLocation(latitude: 43.0695660, longitude: -89.4337170, clueName: "Stump", password: "password", clueImage: "clue10.heic")
    ])
    
    if UserDefaults.standard.value(forKey: "alreadyLaunched") as? Bool == nil || UserDefaults.standard.value(forKey: "alreadyLaunch") as? Bool == false {
      for location in locations {
        LocationsStorage.shared.saveLocationOnDisk(location)
      }
      UserDefaults.standard.set(true, forKey: "alreadyLaunched")
      UserDefaults.standard.set(0, forKey: "maxUnlockedIndex")
    }
    
    // Initialize sign-in
    GIDSignIn.sharedInstance()?.clientID = "945241195780-60m2nqcbkltmm0boqvc5ujl8qsat54jd.apps.googleusercontent.com"
    GIDSignIn.sharedInstance()?.delegate = self

    return true
  }
  
  @available(iOS 9.0, *)
  func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
    return GIDSignIn.sharedInstance().handle(url)
  }
  
  func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
            withError error: Error!) {
    if let error = error {
      if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
        print("The user has not signed in before or they have since signed out.")
      } else {
        print("\(error.localizedDescription)")
      }
      return
    }
    // Perform any operations on signed in user here.
//    let userId = user.userID                  // For client-side use only!
//    let idToken = user.authentication.idToken // Safe to send to the server
//    let fullName = user.profile.name
//    let givenName = user.profile.givenName
//    let familyName = user.profile.familyName
//    let email = user.profile.email
    // ...
  }
  
  func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
            withError error: Error!) {
    // Perform any operations when the user disconnects from app here.
    // ...
  }
  
  func createLocations(_ info: [SimpleLocation]) -> [Location] {
    var retLocations: [Location] = []
    for (index, simple) in info.enumerated() {
      let coordinate: CLLocationCoordinate2D = simple.coordinate
      let clueName: String = simple.clueName
      let password: String = simple.password
      let clueImage: String = simple.clueImage
      var unlocked: Bool = false
      if index == 0 {
        unlocked = true
      }
      let newLocation: Location = Location(coordinate, date: Date(), descriptionString: clueName, unlocked: unlocked, password: password, clueImage: clueImage)
      retLocations.append(newLocation)
    }
    return retLocations
  }
}

class SimpleLocation {
  var coordinate: CLLocationCoordinate2D
  var clueName: String
  var password: String
  var clueImage: String
  
  init(latitude: Double, longitude: Double, clueName: String, password: String, clueImage: String) {
    self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    self.clueName = clueName
    self.password = password
    self.clueImage = clueImage
  }
}

