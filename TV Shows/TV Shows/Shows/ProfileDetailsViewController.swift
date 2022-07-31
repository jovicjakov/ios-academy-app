//
//  ProfileDetailsViewController.swift
//  TV Shows
//
//  Created by Jakov on 31.07.2022..
//

import UIKit
import Alamofire
import MBProgressHUD

let NotificationDidLogout = "NotificationDidLogout"

class ProfileDetailsViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var userPhotoImageView: UIImageView!
    @IBOutlet weak var changePhotoButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    // MARK: - Properties
    
    private var recievedAuthInfo: AuthInfo!
    private var recievedUserData: UserResponse!
    private var imagePicker = UIImagePickerController()
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let decodedData = UserDefaults.standard.object(forKey: "SavedAuthInfo") as? Data {
            if let authInfoData = try? JSONDecoder().decode(AuthInfo.self, from: decodedData) {
                self.recievedAuthInfo = authInfoData
            }
        }
        getUserData()
        setupUI()
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            userPhotoImageView.contentMode = .scaleAspectFit
            userPhotoImageView.image = pickedImage
        }
        storeImage(userPhotoImageView.image!)
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    // MARK: - Actions
    
    @IBAction func changePhotoButtonClicked() {
        imagePicker.modalPresentationStyle = UIModalPresentationStyle.currentContext
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }
    
    @IBAction func logoutButtonClicked() {
        let notification = Notification(
            name: Notification.Name(rawValue: NotificationDidLogout),
            object: nil
        )
        dismiss(animated: true, completion: {
            UserDefaults.standard.removeObject(forKey: "SavedAuthInfo")
            NotificationCenter.default.post(notification)
        })
    }
    
    // MARK: - Utility methods
    
    private func setupUI() {
        userPhotoImageView.layer.cornerRadius = userPhotoImageView.frame.height/2
        userPhotoImageView.clipsToBounds = true
        
        let closeViewItem = UIBarButtonItem(
            title: "Close",
            style: .plain,
            target: self,
            action: #selector(closeView)
        )
        closeViewItem.tintColor = UIColor.init(red: 0.322, green: 0.212, blue: 0.549, alpha: 1)
        navigationItem.leftBarButtonItem = closeViewItem
    }
    @objc
    private func closeView() {
        self.dismiss(animated: true)
    }
    
    private func storeImage(_ image: UIImage) {
        guard
            let imageData = image.jpegData(compressionQuality: 0.9)
        else { return }
        
        let requestData = MultipartFormData()
        requestData.append(
            imageData,
            withName: "image",
            fileName: "image.jpg",
            mimeType: "image/jpg"
        )
        
        AF
            .upload(
                multipartFormData: requestData,
                to: "https://tv-shows.infinum.academy/users", method: .put
            )
            .validate()
            .responseDecodable(of: UserResponse.self) { dataResponse in
                print(dataResponse)
            }
    }
}

// MARK: - GET review + automatic JSON parsing

private extension ProfileDetailsViewController {
    
    func getUserData() {
        MBProgressHUD.showAdded(to: view, animated: true)
        
        AF.request(
            "https://tv-shows.infinum.academy/users/me",
            method: .get,
            headers: HTTPHeaders(recievedAuthInfo.headers)
        )
        .validate()
        .responseDecodable(of: UserResponse.self) { [weak self] dataResponse in
            guard let self = self else { return }
            MBProgressHUD.hide(for: self.view, animated: true)
            switch dataResponse.result {
            case .success(let userResponse):
                self.recievedUserData = userResponse
                self.emailLabel.text = userResponse.user.email
                self.userPhotoImageView.kf.setImage(
                    with: URL(string: userResponse.user.imageUrl ?? "no url"),
                    placeholder: UIImage(named: "ic-profile-placeholder")
                )
                print("API/Serialization success: \(userResponse)")
            case .failure(let error):
                print("API/Serialization failure: \(error)")
            }
        }
    }
}



