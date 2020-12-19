//
//  ChannelTableViewController.swift
//  ChatApp
//
//  Created by Artyom Mihailovich on 12/19/20.
//

import UIKit

class ChannelTableViewController: UITableViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var avatarImageViewOutlet: UIImageView!
    @IBOutlet weak var nameLabelOutlet: UILabel!
    @IBOutlet weak var membersLabelOutlet: UILabel!
    @IBOutlet weak var aboutTextViewOutlet: UITextView!
    
    
    //MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        
    }

    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 0
    }
}
