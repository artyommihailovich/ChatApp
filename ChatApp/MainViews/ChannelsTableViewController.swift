//
//  ChannelsTableViewController.swift
//  ChatApp
//
//  Created by Artyom Mihailovich on 12/18/20.
//

import UIKit

class ChannelsTableViewController: UITableViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var channelsSegmentOutlet: UISegmentedControl!
    
    
    //MARK: - Variables
    
    var allchannels: [Channel] = []
    var subscribedChannels: [Channel] = []
    
    
    //MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .always
        self.title = "Channels"
        tableView.tableFooterView = UIView()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 ///channelsSegmentOutlet.selectedSegmentIndex == 0 ? subscribedChannels.count : allchannels.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ChannelTableViewCell
//        let channel = channelsSegmentOutlet.selectedSegmentIndex == 0 ? subscribedChannels[indexPath.row ] : allchannels[indexPath.row]
//        
//        cell.configure(channel: channel)
        
        return cell
    }
    
    
    //MARK: - IBActions
    
    @IBAction func channelsSegmentValueChanged(_ sender: Any) {
        
    }
}
