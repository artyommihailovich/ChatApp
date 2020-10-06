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
        
        
        configureTextField()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showUserInfo()
    }
    
    
    //MARK: - TableView delegate
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        // Coloring huge separators
        headerView.backgroundColor = UIColor(named: "TableViewBackgroundColor")
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // Clear huge spacer of header
        return section == 0 ? 0.0 : 30
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        //TODO: Show status view
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
    
    
    //MARK: - Configure
    
    func configureTextField(){
        usernameTextField.delegate = self
        usernameTextField.clearButtonMode = .whileEditing
    }
}


    //MARK: - Extension

extension EditProfileTableViewController: UITextFieldDelegate {
    // Change keyboard button name
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameTextField {
            
            if textField.text != "" {
                
                if var user = User.currentUser {
                    user.username = textField.text!
                    saveUserLocally(user)
                    FirebaseUserListener.shared.saveUserToFirestore(user)
                }
            }
            textField.resignFirstResponder()
            return false
        }
        return true
    }
}
