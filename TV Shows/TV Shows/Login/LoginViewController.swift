//
//  LoginViewController.swift
//  TV Shows
//
//  Created by Jakov on 12.07.2022..
//

import UIKit
import MBProgressHUD
import Alamofire

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
    private var userRes : UserResponse?
    
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
    
    @IBAction func loginButtonTapped() {
        if (!emailTextField.text!.isEmpty && !passwordTextField.text!.isEmpty) {
            loginUserWith(email: emailTextField.text!, password: passwordTextField.text!)
            pushHomeViewController()
        }
        
    }
    
    @IBAction func registerButtonTapped() {
        if (!emailTextField.text!.isEmpty && !passwordTextField.text!.isEmpty) {
            registerUserWith(email: emailTextField.text!, password: passwordTextField.text!)
            pushHomeViewController()
        }
    }
    
    // MARK: - Utility methods
    
    @objc private func pushHomeViewController() {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        navigationController?.pushViewController(destinationVC, animated: true)
    }
    
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
}


// MARK: - Register + automatic JSON parsing

private extension LoginViewController {
    
    func registerUserWith(email: String, password: String) {
        MBProgressHUD.showAdded(to: view, animated: true)
        
        let parameters: [String: String] = [
            "email": email,
            "password": password,
            "password_confirmation": password
        ]
        
        AF
            .request(
                "https://tv-shows.infinum.academy/users",
                method: .post,
                parameters: parameters,
                encoder: JSONParameterEncoder.default
            )
            .validate()
            .responseDecodable(of: UserResponse.self) { [weak self] dataResponse in
                guard let self = self else { return }
                MBProgressHUD.hide(for: self.view, animated: true)
                switch dataResponse.result {
                case .success(let userResponse):
                    self.userRes = userResponse
                    print("API/Serialization success: \(userResponse)")
                case .failure(let error):
                    print("API/Serialization failure: \(error)")
                }
            }
    }
    
}



// MARK: - Login + automatic JSON parsing

private extension LoginViewController {
    
    func loginUserWith(email: String, password: String) {
        MBProgressHUD.showAdded(to: view, animated: true)
        
        let parameters: [String: String] = [
            "email": email,
            "password": password
        ]
        
        AF
            .request(
                "https://tv-shows.infinum.academy/users/sign_in",
                method: .post,
                parameters: parameters,
                encoder: JSONParameterEncoder.default
            )
            .validate()
            .responseDecodable(of: UserResponse.self) { [weak self] dataResponse in
                guard let self = self else { return }
                MBProgressHUD.hide(for: self.view, animated: true)
                switch dataResponse.result {
                case .success(let userResponse):
                    self.userRes = userResponse
                    let headers = dataResponse.response?.headers.dictionary ?? [:]
                    self.handleSuccesfulLogin(for: userResponse.user, headers: headers)
                case .failure(let error):
                    print("API/Serialization failure: \(error)")                }
            }
    }
    
    // Headers will be used for subsequent authorization on next requests
    func handleSuccesfulLogin(for user: User, headers: [String: String]) {
        guard let authInfo = try? AuthInfo(headers: headers) else {
            print("Missing headers")
            return
        }
        print("\(user)\n\n\(authInfo)")
    }
}



