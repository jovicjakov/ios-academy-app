//
//  LoginViewController.swift
//  TV Shows
//
//  Created by Jakov on 12.07.2022..
//

import UIKit

final class LoginViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var incrementButton: UIButton!
    
    // MARK: - Properties
    
    private var currentValue: Int = 0 {
            didSet {
                titleLabel.text = "\(currentValue)"
            }
        }
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Actions
    
    @IBAction private func tappedButton() {
        currentValue += 1
    }
    
    // MARK: - Utility methods
    
    private func setupUI() {
        incrementButton.layer.cornerRadius = 15
        incrementButton.backgroundColor = UIColor.lightGray
    }
    
}
