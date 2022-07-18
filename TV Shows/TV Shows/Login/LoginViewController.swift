//
//  LoginViewController.swift
//  TV Shows
//
//  Created by Jakov on 12.07.2022..
//

import UIKit

final class LoginViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var loginButton: UIButton!
    @IBOutlet private weak var registerButton: UIButton!
    @IBOutlet private weak var checkboxButton: UIButton!
    @IBOutlet private weak var showButton: UIButton!
    @IBOutlet private weak var continueLabel: UILabel!
    
    // MARK: - Properties
    
    private var checkboxPressed = false
    private var showbtnPressed = false
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        disableLogin()
        setupUI()
    }
    
    // MARK: - Actions

    @IBAction func checkboxButtonTapped() {
        checkRememberMe()
    }
    
    @IBAction func showButtonTapped() {
        checkShow()
    }
    
    @IBAction func emailChanged() {
        enableLogin()
    }
    // MARK: - Utility methods
    
    private func disableLogin() {
        
        checkboxButton.isEnabled = false
        if let image = UIImage(named: "ic-checkbox-unselected") {
            checkboxButton.setImage(image, for: .disabled)
        }
        
        loginButton.isEnabled = false
        loginButton.setTitleColor(UIColor.gray, for: .disabled)
        
        registerButton.isEnabled = false
        registerButton.setTitleColor(UIColor.gray, for: .disabled)
        
        continueLabel.isHidden = true
        showButton.isHidden = true
    
    }
    
    private func enableLogin() {
            loginButton.isEnabled = true
            registerButton.isEnabled = true
            checkboxButton.isEnabled = true
            continueLabel.isHidden = false
            showButton.isHidden = false
    }
    
    private func setupUI() {
        loginButton.layer.cornerRadius = 25
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        registerButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        underlineTextField(textField:emailTextField)
        underlineTextField(textField:passwordTextField)
        
        emailTextField.attributedPlaceholder = NSAttributedString(
            string: "  Email",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightText]
        )
        
        passwordTextField.attributedPlaceholder = NSAttributedString(
            string: "  Password",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightText]
        )
        
        checkRememberMe()
        checkShow()
    }
    
    private func underlineTextField(textField:UITextField) {
        let bottomLayer = CALayer()
        bottomLayer.frame = CGRect(x: -5, y:textField.frame.height, width: textField.frame.width - 35, height: 1)
        bottomLayer.backgroundColor = UIColor.white.cgColor
        textField.layer.addSublayer(bottomLayer)
    }
    
    private func checkRememberMe() {
        if !checkboxPressed {
            if let image = UIImage(named: "ic-checkbox-selected") {
                checkboxButton.setImage(image, for: .normal)
            }
        } else {
            if let image = UIImage(named: "ic-checkbox-unselected") {
                checkboxButton.setImage(image, for: .normal)
            }
        }
        checkboxPressed = !checkboxPressed
    }
    
    private func checkShow() {
        if !showbtnPressed {
            if let image = UIImage(named: "ic-visible") {
                showButton.setImage(image, for: .normal)
            }
            passwordTextField.isSecureTextEntry = true
        } else {
            if let image = UIImage(named: "ic-invisible") {
                showButton.setImage(image, for: .normal)
            }
            passwordTextField.isSecureTextEntry = false
        }
        showbtnPressed = !showbtnPressed
    }
    
    private func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        let text = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        
        if !text.isEmpty{
            loginButton.isUserInteractionEnabled = true
            registerButton.isUserInteractionEnabled = true
        } else {
            loginButton.isUserInteractionEnabled = false
            registerButton.isUserInteractionEnabled = false
        }
        return true
    }
    
}


