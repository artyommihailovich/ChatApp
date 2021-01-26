//
//  UsersTableViewController.swift
//  ChatApp
//
//  Created by Artyom Mihailovich on 10/23/20.
//

import UIKit

class UsersTableViewController: UITableViewController {

    //MARK: - Variables
    
    var allUsers: [User] = []
    var filteredUsers: [User] = []

    let searchController = UISearchController(searchResultsController: nil)
    
    
    //MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Refresh controller
        self.refreshControl = UIRefreshControl()
        self.tableView.refreshControl = self.refreshControl
        
        
        tableView.tableFooterView = UIView()
        setupSearchController()
        downloadUsers()
       // configureBackButton()
        //createDummyUsers()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    //MARK: - Configuretion
    
//    private func configureBackButton() {
//        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(weight: .light))?.withTintColor(.systemOrange, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(backButtonPressed))
//    }
    
    
    //MARK: - Actions
    
    @objc
    func backButtonPressed() {
        self.navigationController?.popViewController(animated: false)
    }
    
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return searchController.isActive ? filteredUsers.count : allUsers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! UserTableViewCell
        let user = searchController.isActive ? filteredUsers[indexPath.row] : allUsers[indexPath.row]

        cell.configure(user: user)
        
        return cell
    }
    
    
    //MARK: - TableView delegate
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(named: "TableViewBackgroundColor")
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let user = searchController.isActive ? filteredUsers[indexPath.row] : allUsers[indexPath.row]
        
        showUserProfile(user)
    }
    
    
    //MARK: - Download users
    
    private func downloadUsers() {
        FirebaseUserListener.shared.downloadAllUsersFromFirebase { (allFirebaseUsers) in
            self.allUsers = allFirebaseUsers
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    
    //MARK: - Setup search controller
    
    private func setupSearchController() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        
        searchController.searchBar.placeholder = "Search user"
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        definesPresentationContext = true
    }
    
    private func filteredContentForSearchText(searchText: String) {
        filteredUsers = allUsers.filter({ (user) -> Bool in
            return user.username.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
    
    
    //MARK: - UIScrollView delegate

    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("Refresh")
        
         if self.refreshControl!.isRefreshing {
            self.downloadUsers()
            self.refreshControl!.endRefreshing()
        }
    }
    
    
    //MARK: - Navigation
    
    private func showUserProfile(_ user: User) {
        let profileView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ProfileView") as! ProfileTableViewController
        
        profileView.user = user
        self.navigationController?.pushViewController(profileView, animated: true)
        
    }
}


    //MARK: - Extensions

extension UsersTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filteredContentForSearchText(searchText: searchController.searchBar.text!)
    }
}
