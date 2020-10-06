//
//  SettingsTableViewController.swift
//  ChatApp
//
//  Created by Artyom Mihailovich on 10/2/20.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    //MARK: - IBOutlets
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var appVersionLabel: UILabel!
    
    
    //MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showUserInfo()
    }
    
    
    //MARK: - IBAction
    
    @IBAction func tellAFriendsButtonPressed(_ sender: Any) {
        print("Tell a friend")
    }
    
    @IBAction func termsAndConditionButtonPressed(_ sender: Any) {
        print("Terms and condition")
    }
    
    @IBAction func logOutButtonPressed(_ sender: Any) {
        FirebaseUserListener.shared.logOutCurrentUser { (error) in
            if error == nil {
                let loginView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "loginView")
                
                DispatchQueue.main.async {
                    loginView.modalPresentationStyle = .fullScreen
                    self.present(loginView, animated: true, completion: nil)
                }
            }
        }
    }
    
    
    //MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        // Coloring huge separators
        headerView.backgroundColor = UIColor(named: "TableViewBackgroundColor")
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // Change space of sections
        return section == 0 ? 0.0 : 10
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 && indexPath.row == 0 {
            performSegue(withIdentifier: "SettingsToEditProfileSeg", sender: self)
        }
    }
    
    
    //MARK: - Update user interface
    
    func showUserInfo() {
        if let user = User.currentUser {
            usernameLabel.text = user.username
            statusLabel.text = user.status
            appVersionLabel.text = "App Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")"
            
            if user.avatarLink != "" {
                //Download and set avatar image
                
            }
        }
    }
}
