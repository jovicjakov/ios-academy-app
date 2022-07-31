//
//  Shows.swift
//  TV Shows
//
//  Created by Jakov on 19.07.2022..
//

import UIKit
import MBProgressHUD
import Alamofire
import Kingfisher

class Shows: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    
    public var recievedLoginData: UserResponse!
    public var recievedAuthInfo: AuthInfo!
    private var showsResponse: ShowsResponse?
    private var show: Show?
    private var notificationToken: NSObjectProtocol?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subscribeToNotification()
        setupUI()
        setupTableView()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(notificationToken!)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! ShowDetailsViewController
        let selectedIndexPath = tableView.indexPathForSelectedRow!
        destination.show = showsResponse?.shows[selectedIndexPath.row]
        destination.authInfo = recievedAuthInfo
        let backItem = UIBarButtonItem()
        backItem.title = "Shows"
        navigationItem.backBarButtonItem = backItem
    }
    
    @objc
    private func presentProfileDetailsViewController() {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let profileDetailsViewController = storyboard.instantiateViewController(withIdentifier: "ProfileDetailsViewController") as! ProfileDetailsViewController
        let navigationController = UINavigationController(rootViewController: profileDetailsViewController)
        present(navigationController, animated: true)
    }
}

// MARK: - UITableView

extension Shows: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = showsResponse?.shows[indexPath.row].title
        cell.detailTextLabel?.isEnabled = false
        show = showsResponse?.shows[indexPath.row]
        guard
            let image_url = show?.image_url,
            !image_url.isEmpty
        else {
            return cell
        }
        cell.imageView!.layer.cornerRadius = 4
        cell.imageView!.clipsToBounds = true
        cell.imageView?.kf.setImage(
            with: URL(string: image_url),
            placeholder: UIImage(named: "ic-show-placeholder-vertical"))
        return cell
    }
}

// MARK: - GET show data + automatic JSON parsing

private extension Shows {
    
    func getShowsData(completed: @escaping () -> ()) {
        MBProgressHUD.showAdded(to: view, animated: true)
        AF
            .request(
                "https://tv-shows.infinum.academy/shows",
                method: .get,
                parameters: ["page": "1", "items": "100"],
                headers: HTTPHeaders(recievedAuthInfo.headers)
            )
            .validate()
            .responseDecodable(of: ShowsResponse.self) { [weak self] dataResponse in
                guard let self = self else { return }
                MBProgressHUD.hide(for: self.view, animated: true)
                switch dataResponse.result {
                case .success(let showsResponse):
                    DispatchQueue.main.async {
                        self.showsResponse = showsResponse
                    }
                    print("API/Serialization success: \(showsResponse)")
                case .failure(let error):
                    print("API/Serialization failure: \(error)")
                }
                completed()
            }
    }
}

// MARK: - Private extension

private extension Shows {
    
    func subscribeToNotification() {
        let loginViewController = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        notificationToken = NotificationCenter
            .default
            .addObserver(
                forName: Notification.Name(rawValue: NotificationDidLogout),
                object: nil,
                queue: nil) { _ in
                    DispatchQueue.main.async {
                        self.navigationController?.popToRootViewController(animated: false)
                        self.navigationController?.setViewControllers([loginViewController], animated: false)
                    }
                }
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        getShowsData {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func setupUI() {
        let profileDetailsItem = UIBarButtonItem(
            image: UIImage(named: "ic-profile"),
            style: .plain,
            target: self,
            action: #selector(presentProfileDetailsViewController)
        )
        profileDetailsItem.tintColor = UIColor.init(red: 0.322, green: 0.212, blue: 0.549, alpha: 1)
        navigationItem.rightBarButtonItem = profileDetailsItem
        
        if let decodedData = UserDefaults.standard.object(forKey: "SavedAuthInfo") as? Data {
            if let authInfoData = try? JSONDecoder().decode(AuthInfo.self, from: decodedData) {
                self.recievedAuthInfo = authInfoData
            }
        }
    }
}
