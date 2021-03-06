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

private class PopUpWindowView: UIView {
  
  let popupView = UIView(frame: CGRect.zero)
  let popupTitle = UILabel(frame: CGRect.zero)
  let popupText = UILabel(frame: CGRect.zero)
  let popupButton = UIButton(frame: CGRect.zero)
  
  let BorderWidth: CGFloat = 2.0
  
  init() {
    super.init(frame: CGRect.zero)
    
    // Semi-transparent background
    backgroundColor = UIColor.black.withAlphaComponent(0.3)
    
    // Popup Background
    popupView.backgroundColor = UIColor.blue
    popupView.layer.borderWidth = BorderWidth
    popupView.layer.masksToBounds = true
    popupView.layer.borderColor = UIColor.white.cgColor
    
    // Popup Title
    popupTitle.textColor = UIColor.white
    popupTitle.backgroundColor = UIColor.yellow
    popupTitle.layer.masksToBounds = true
    popupTitle.adjustsFontSizeToFitWidth = true
    popupTitle.clipsToBounds = true
    popupTitle.font = UIFont.systemFont(ofSize: 23.0, weight: .bold)
    popupTitle.numberOfLines = 1
    popupTitle.textAlignment = .center
    
    // Popup Text
    popupText.textColor = UIColor.white
    popupText.font = UIFont.systemFont(ofSize: 16.0, weight: .semibold)
    popupText.numberOfLines = 0
    popupText.textAlignment = .center
    
    // Popup Button
    popupButton.setTitleColor(UIColor.white, for: .normal)
    popupButton.titleLabel?.font = UIFont.systemFont(ofSize: 23.0, weight: .bold)
    popupButton.backgroundColor = UIColor.yellow
    
    popupView.addSubview(popupTitle)
    popupView.addSubview(popupText)
    popupView.addSubview(popupButton)
    
    // Add the popupView(box) in the PopUpWindowView (semi-transparent background)
    addSubview(popupView)
    
    
    // PopupView constraints
    popupView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
        popupView.widthAnchor.constraint(equalToConstant: 293),
        popupView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        popupView.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
    
    // PopupTitle constraints
    popupTitle.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
        popupTitle.leadingAnchor.constraint(equalTo: popupView.leadingAnchor, constant: BorderWidth),
        popupTitle.trailingAnchor.constraint(equalTo: popupView.trailingAnchor, constant: -BorderWidth),
        popupTitle.topAnchor.constraint(equalTo: popupView.topAnchor, constant: BorderWidth),
        popupTitle.heightAnchor.constraint(equalToConstant: 55)
        ])
    
    
    // PopupText constraints
    popupText.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
        popupText.heightAnchor.constraint(greaterThanOrEqualToConstant: 67),
        popupText.topAnchor.constraint(equalTo: popupTitle.bottomAnchor, constant: 8),
        popupText.leadingAnchor.constraint(equalTo: popupView.leadingAnchor, constant: 15),
        popupText.trailingAnchor.constraint(equalTo: popupView.trailingAnchor, constant: -15),
        popupText.bottomAnchor.constraint(equalTo: popupButton.topAnchor, constant: -8)
        ])

    
    // PopupButton constraints
    popupButton.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
        popupButton.heightAnchor.constraint(equalToConstant: 44),
        popupButton.leadingAnchor.constraint(equalTo: popupView.leadingAnchor, constant: BorderWidth),
        popupButton.trailingAnchor.constraint(equalTo: popupView.trailingAnchor, constant: -BorderWidth),
        popupButton.bottomAnchor.constraint(equalTo: popupView.bottomAnchor, constant: -BorderWidth)
        ])
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

class PopUpWindow: UIViewController {
  
  private let popUpWindowView = PopUpWindowView()
  
  init(title: String, text: String, buttontext: String) {
    super.init(nibName: nil, bundle: nil)
    modalTransitionStyle = .crossDissolve
    modalPresentationStyle = .overFullScreen
    
    popUpWindowView.popupTitle.text = title
    popUpWindowView.popupText.text = text
    popUpWindowView.popupButton.setTitle(buttontext, for: .normal)
    
    popUpWindowView.popupButton.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
    
    view = popUpWindowView
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  @objc func dismissView() {
    self.dismiss(animated: true, completion: nil)
  }
  
}
