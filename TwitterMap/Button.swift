//
//  Button.swift
//  BikeShare
//
//  Created by Russell Weber on 2019-05-22.
//  Copyright © 2019 Russell Weber. All rights reserved.
//

import UIKit

class Button: UIButton {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.backgroundColor = UIColor.white.cgColor
        self.clipsToBounds = true
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.layer.masksToBounds = false
        self.layer.shadowRadius = 8.0
        self.layer.shadowOpacity = 0.75
        self.layer.cornerRadius = self.frame.width / 2
        self.layer.borderWidth = 5
        self.layer.borderColor = UIColor.white.cgColor
        
    }
    
    
    init() {
        let frame = CGRect(x: 160, y: 100, width: 50, height: 50)
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}
