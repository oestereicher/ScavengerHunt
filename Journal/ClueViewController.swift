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

import Foundation
import UIKit

class ClueViewController: UIViewController {
  
  
  @IBOutlet weak var img: UIImageView!
  var image: UIImage?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    img.image = image
    
//    let imageZoomView = ImageZoomView(frame: CGRect(x: 0, y: 0, width: 300, height: 300), image: image!)
//    imageZoomView.layer.borderColor = UIColor.black.cgColor
//    imageZoomView.layer.borderWidth = 5
//    imageView = imageZoomView
    
    img.isUserInteractionEnabled = true

    let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(self.pinchGesture))
    img.addGestureRecognizer(pinchGesture)
    
    // now panning
    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.dragImg(_:)))
    img.addGestureRecognizer(panGesture)
  }
  
  @objc func pinchGesture(sender: UIPinchGestureRecognizer) {
//    sender.view?.transform = (sender.view?.transform.scaledBy(x: sender.scale, y: sender.scale))!
//    sender.scale = 1.0
    if let view = sender.view {
      switch sender.state {
      case .changed:
        let pinchCenter = CGPoint(x: sender.location(in: view).x - view.bounds.midX, y: sender.location(in: view).y - view.bounds.midY)
        let transform = view.transform.translatedBy(x: pinchCenter.x, y: pinchCenter.y).scaledBy(x: sender.scale, y: sender.scale).translatedBy(x: -pinchCenter.x, y: -pinchCenter.y)
        view.transform = transform
        sender.scale = 1.0
//      case .ended:
//        UIView.animate(withDuration: 0.2, animations: {view.transform = CGAffineTransform.identity})
      default:
        return
      }
    }
  }
  
  @objc func dragImg(_ sender: UIPanGestureRecognizer) {
    let translation = sender.translation(in: self.view)
    img.center = CGPoint(x: img.center.x + translation.x, y: img.center.y + translation.y)
    sender.setTranslation(CGPoint.zero, in: self.view)
  }
  
//  @objc func scaleImg(_ sender: UIPinchGestureRecognizer) {
//    img.transform = CGAffineTransform(scaleX: sender.scale, y: sender.scale)
//  }
}

class ImageZoomView: UIScrollView, UIScrollViewDelegate {
  var imageView: UIImageView!
  var gestureRecognizer: UITapGestureRecognizer!
  
  convenience init(frame: CGRect, image: UIImage) {
    self.init(frame: frame)
    
    // Creates the image view and adds it as a subview to the scroll view
    imageView = UIImageView(image: image)
    imageView.frame = frame
    imageView.contentMode = .scaleAspectFill
    addSubview(imageView)
    
    setupScrollView(image: image)
    setupGestureRecognizer()
  }
  
  // Sets the scroll view delegate and zoom scale limits
  // Change the `maximumZoomScale` to allow zooming more than 2x
  func setupScrollView(image: UIImage) {
    delegate = self
    
    minimumZoomScale = 1.0
    maximumZoomScale = 2.0
  }
  
  // Sets up the gesture recognizer that receives double taps to auto-zoom
  func setupGestureRecognizer() {
    gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
    gestureRecognizer.numberOfTapsRequired = 2
    addGestureRecognizer(gestureRecognizer)
  }
  
  @objc func handleDoubleTap() {
    if zoomScale == 1 {
      zoom(to: zoomRectForScale(maximumZoomScale, center: gestureRecognizer.location(in: gestureRecognizer.view)), animated: true)
    } else {
      setZoomScale(1, animated: true)
    }
  }
  
  func zoomRectForScale(_ scale: CGFloat, center: CGPoint) -> CGRect {
    var zoomRect = CGRect.zero
    zoomRect.size.height = imageView.frame.size.height / scale
    zoomRect.size.width = imageView.frame.size.width / scale
    let newCenter = convert(center, from: imageView)
    zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
    zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
    return zoomRect
  }
  
  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    return imageView
  }
}
