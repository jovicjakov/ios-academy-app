//
//  CustomTextField.swift
//  TV Shows
//
//  Created by Jakov on 17.07.2022..
//

import UIKit
import Foundation

class CustomTextField: UITextView {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupUnderlinedTextField()
    }
    
    // MARK: Setup
    func setupUnderlinedTextField() {
        let bottomLayer = CALayer()
        bottomLayer.frame = CGRect(x: 0, y:self.frame.height, width: self.frame.width - 35, height: 1)
        bottomLayer.backgroundColor = UIColor.white.cgColor
        self.layer.addSublayer(bottomLayer)
    }

}
