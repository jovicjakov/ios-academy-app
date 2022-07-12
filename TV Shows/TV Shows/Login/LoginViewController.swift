//
//  LoginViewController.swift
//  TV Shows
//
//  Created by Jakov on 12.07.2022..
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    
    var currentValue: Int = 0 {
            didSet {
                counterLabel.text = "\(currentValue)"
            }
        }
    
    @IBAction func tappedButton(_ sender: UIButton) {
        currentValue += 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        button.layer.cornerRadius = 15
        button.backgroundColor = UIColor.lightGray
        
    }
    
}
