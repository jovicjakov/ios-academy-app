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
    @IBOutlet private weak var rememberMeButton: UIButton!
    @IBOutlet private weak var showPasswordButton: UIButton!
    @IBOutlet private weak var continueLabel: UILabel!
    
    // MARK: - Properties
    
    private var userRes : UserResponse?
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        disableLogin()
        setupUI()
    }
    
    // MARK: - Actions
    
    @IBAction func checkboxButtonTapped() {
        rememberMeButton.isSelected.toggle()
        checkRememberMeButton()
    }
    
    @IBAction func showButtonTapped() {
        showPasswordButton.isSelected.toggle()
        checkShowPasswordButton()
    }
    
    @IBAction func emailChanged() {
        enableLogin()
    }
    
    @IBAction func loginButtonTapped() {
        guard
            let email = emailTextField.text,
            let password = passwordTextField.text,
            !email.isEmpty,
            !password.isEmpty
        else {
            return
        }
        loginUserWith(email: email, password: password)
    }
    
    @IBAction func registerButtonTapped() {
        guard
            let email = emailTextField.text,
            let password = passwordTextField.text,
            !email.isEmpty,
            !password.isEmpty
        else {
            return
        }
        registerUserWith(email: email, password: password)
    }
    
    // MARK: - Utility methods
    
    @objc private func pushHomeViewController() {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        navigationController?.pushViewController(destinationVC, animated: true)
    }
    
    private func disableLogin() {
        rememberMeButton.isEnabled = false
        rememberMeButton.setImage(UIImage(named: "ic-checkbox-unselected"), for: .disabled)
        loginButton.isEnabled = false
        loginButton.setTitleColor(.gray, for: .disabled)
        registerButton.isEnabled = false
        registerButton.setTitleColor(.gray, for: .disabled)
        continueLabel.isHidden = true
        showPasswordButton.isHidden = true
    }
    
    private func enableLogin() {
        loginButton.isEnabled = true
        registerButton.isEnabled = true
        rememberMeButton.isEnabled = true
        continueLabel.isHidden = false
        showPasswordButton.isHidden = false
    }
    
    private func setupUI() {
        loginButton.layer.cornerRadius = 25
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        registerButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        
        viewDidLayoutSubviews()
        
        emailTextField.attributedPlaceholder = NSAttributedString(
            string: "  Email",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightText]
        )
        
        passwordTextField.attributedPlaceholder = NSAttributedString(
            string: "  Password",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightText]
        )
        
        checkRememberMeButton()
        checkShowPasswordButton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        underlineTextField(textField: emailTextField)
        underlineTextField(textField: passwordTextField)
    }
    
    private func underlineTextField(textField: UITextField) {
        let bottomLayer = CALayer()
        bottomLayer.frame = CGRect(
            x: -5,
            y: textField.frame.height,
            width: textField.frame.width - 35,
            height: 1
        )
        bottomLayer.backgroundColor = UIColor.white.cgColor
        textField.layer.addSublayer(bottomLayer)
    }
    
    private func checkRememberMeButton() {
        if rememberMeButton.isSelected {
            rememberMeButton.setImage(UIImage(named: "ic-checkbox-selected"), for: .selected)
        } else {
            rememberMeButton.setImage(UIImage(named: "ic-checkbox-unselected"), for: .normal)
        }
    }
    
    private func checkShowPasswordButton() {
        if showPasswordButton.isSelected {
            showPasswordButton.setImage(UIImage(named: "ic-invisible"), for: .selected)
            passwordTextField.isSecureTextEntry = false
        } else {
            showPasswordButton.setImage(UIImage(named: "ic-visible"), for: .normal)
            passwordTextField.isSecureTextEntry = true
        }
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
                    self.pushHomeViewController()
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
                    self.pushHomeViewController()
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
