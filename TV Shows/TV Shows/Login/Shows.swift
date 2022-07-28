//
//  Shows.swift
//  TV Shows
//
//  Created by Jakov on 19.07.2022..
//

import UIKit
import MBProgressHUD
import Alamofire

final class Shows: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    
    public var recievedLoginData: UserResponse?
    public var recievedAuthInfo: AuthInfo?
    private var showsResponse: ShowsResponse?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
}

// MARK: - UITableView

extension Shows: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        //getShowsData()
        cell.textLabel?.text = showsResponse?.shows[indexPath.row].title
        return cell
    }
}

// MARK: - Authenticate + automatic JSON parsing

private extension Shows {
    
    func getShowsData(completed: @escaping () -> ()) {
        MBProgressHUD.showAdded(to: view, animated: true)
        AF
            .request(
                "https://tv-shows.infinum.academy/shows",
                method: .get,
                parameters: ["page": "1", "items": "100"],
                headers: HTTPHeaders(recievedAuthInfo!.headers)
            )
            .validate()
            .responseDecodable(of: ShowsResponse.self) { [weak self] dataResponse in
                guard let self = self else { return }
                MBProgressHUD.hide(for: self.view, animated: true)
                switch dataResponse.result {
                case .success(let showsResponse):
                    self.showsResponse = showsResponse
                    print("API/Serialization success: \(showsResponse)")
                case .failure(let error):
                    print("API/Serialization failure: \(error)")
                }
            }
    }
}

// MARK: - Utility methods

private extension Shows {
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        getShowsData {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}






