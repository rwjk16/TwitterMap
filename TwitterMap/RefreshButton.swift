//
//  RefreshButton.swift
//  BikeShare
//
//  Created by Russell Weber on 2019-05-23.
//  Copyright © 2019 Russell Weber. All rights reserved.
//

import UIKit

class RefreshButton: Button {
  
  var originalButtonText: String?
  var activityIndicator: UIActivityIndicatorView!
  
  func rotateImage() {
    UIView.animate(withDuration: 2.0) {
      self.transform = self.transform.rotated(by: -.pi/1.0000000000001)
    }
  }
  
  func showLoading() {
    originalButtonText = self.titleLabel?.text
    self.setTitle("", for: .normal)
    
    if (activityIndicator == nil) {
      activityIndicator = createActivityIndicator()
    }
    
    showSpinning()
  }
  
  func hideLoading() {
    self.setTitle(originalButtonText, for: .normal)
    activityIndicator.stopAnimating()
  }
  
  private func createActivityIndicator() -> UIActivityIndicatorView {
    let activityIndicator = UIActivityIndicatorView()
    activityIndicator.hidesWhenStopped = true
    activityIndicator.color = .lightGray
    return activityIndicator
  }
  
  private func showSpinning() {
    activityIndicator.translatesAutoresizingMaskIntoConstraints = false
    self.addSubview(activityIndicator)
    centerActivityIndicatorInButton()
    activityIndicator.startAnimating()
  }
  
  private func centerActivityIndicatorInButton() {
    let xCenterConstraint = NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: activityIndicator, attribute: .centerX, multiplier: 1, constant: 0)
    self.addConstraint(xCenterConstraint)
    
    let yCenterConstraint = NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: activityIndicator, attribute: .centerY, multiplier: 1, constant: 0)
    self.addConstraint(yCenterConstraint)
  }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
