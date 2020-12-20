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
    
    
    //MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if channelsSegmentOutlet.selectedSegmentIndex == 1 {
            
            showChannelView(allchannels[indexPath.row])
        } else {
            showChat(subscribedChannels[indexPath.row])
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if channelsSegmentOutlet.selectedSegmentIndex == 1 {
            return false
        } else {
            return subscribedChannels[indexPath.row].adminId != User.currentId
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            var channelToUnSubscribed = subscribedChannels[indexPath.row]
            subscribedChannels.remove(at: indexPath.row)
            
            if let index = channelToUnSubscribed.memberIds.firstIndex(of: User.currentId) {
                channelToUnSubscribed.memberIds.remove(at: index)
            }
            
            FirebaseChannelListener.shared.saveChannel(channelToUnSubscribed)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
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
        FirebaseChannelListener.shared.downloadSubscribedChannels { (subscribedChannels) in
            
            self.subscribedChannels = subscribedChannels
            if self.channelsSegmentOutlet.selectedSegmentIndex == 0 {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    
    //MARK: - UIScroll view delegate
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if self.refreshControl!.isRefreshing {
            self.downloadAllChannels()
            self.refreshControl!.endRefreshing()
        }
    }
    
    
    //MARK: - Navigation
    
    private func  showChannelView(_ channel: Channel) {
        let channelVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ChannelView") as! ChannelDetailTableViewController
        
        channelVC.channel = channel
        channelVC.delegate = self
        self.navigationController?.pushViewController(channelVC, animated: true)
    }
    
    private func showChat(_ channel: Channel) {
         let channelChatVC = ChannelChatViewController(channel: channel)
        
        channelChatVC.hidesBottomBarWhenPushed  = true
        navigationController?.pushViewController(channelChatVC, animated: true)
    }
}


    //MARK: - Extensions

extension ChannelsTableViewController : ChannelDetailTableViewControllerDelegate {
    
    func didClickFollow() {
        self.downloadAllChannels()
    }
    
}

