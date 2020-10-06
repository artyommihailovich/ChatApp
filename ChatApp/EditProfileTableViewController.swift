//
//  EditProfileTableViewController.swift
//  ChatApp
//
//  Created by Artyom Mihailovich on 10/6/20.
//

import UIKit

class EditProfileTableViewController: UITableViewController {

    //MARK: - IBOutlets
    
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    
    
    //MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        
        showUserInfo()
    }
    
    
    //MARK: - TableView delegate
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        // Coloring huge separators
        headerView.backgroundColor = UIColor(named: "TableViewBackgroundColor")
        
        return headerView
    }
    
    
    //MARK: - Update UI
    
    private func showUserInfo() {
        
        if let user = User.currentUser {
            usernameTextField.text = user.username
            statusLabel.text = user.status
            
            if user.avatarLink != "" {
                // Set avatar
            }
        }
    }
}
