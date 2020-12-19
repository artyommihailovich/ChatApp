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
        tableView.tableFooterView = UIView()
        
        self.title = "Channels"
        self.refreshControl = UIRefreshControl()
        self.tableView.refreshControl = self.refreshControl
        
        
        downloadAllChannels()
        downloadSubscribedChannels()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return channelsSegmentOutlet.selectedSegmentIndex == 0 ? subscribedChannels.count : allchannels.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ChannelTableViewCell
        let channel = channelsSegmentOutlet.selectedSegmentIndex == 0 ? subscribedChannels[indexPath.row ] : allchannels[indexPath.row]
        
        cell.configure(channel: channel)
        
        return cell
    }
    
    
    //MARK: - IBActions
    
    @IBAction func channelsSegmentValueChanged(_ sender: Any) {
        
        tableView.reloadData()
    }
    
    
    //MARK: - Download channels
    
    private func downloadAllChannels() {
        
        FirebaseChannelListener.shared.downloadAllChannels {(allChannels) in
            
            self.allchannels = allChannels
   
            if self.channelsSegmentOutlet.selectedSegmentIndex == 1 {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    private func downloadSubscribedChannels() {
        
    }
    
    
    //MARK: - UIScroll view delegate
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if self.refreshControl!.isRefreshing {
            self.downloadAllChannels()
            self.refreshControl!.endRefreshing()
        }
    }
}
