//
//  MyChannelsTableViewController.swift
//  ChatApp
//
//  Created by Artyom Mihailovich on 12/19/20.
//

import UIKit

class MyChannelsTableViewController: UITableViewController {
    
    //MARK: - Variables
    
    var myChannels: [Channel] = []
    
    
    //MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
         tableView.tableFooterView = UIView()

        downloadUserChannels()
        configureLeftBarButton()
    }
    
    
    //MARK: - Configuration
    
    private func configureLeftBarButton() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(weight: .light))?.withTintColor(.systemOrange, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(backButtonPressed))
    }
    
    
    //MARK: - Download user channels
    
    private func downloadUserChannels() {
        
        FirebaseChannelListener.shared.downloadUserChannelsFromFirebase { (allChannels) in
            
            self.myChannels = allChannels
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    
    //MARK: - IBActions
    
    @IBAction func addBarButtonPressed(_ sender: Any) {
        
        performSegue(withIdentifier: "myChannelsToAddSeg", sender: self)
    }
    
    
    //MARK: - Target actions
    
    @objc
    func backButtonPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    

    //MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return myChannels.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ChannelTableViewCell
        
        cell.configure(channel: myChannels[indexPath.row])
        
        return cell
    }
    
    
    //MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        performSegue(withIdentifier: "myChannelsToAddSeg", sender: myChannels[indexPath.row])
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let channelToDelete = myChannels[indexPath.row]
            
            myChannels.remove(at: indexPath.row)
                
            FirebaseChannelListener.shared.deleteChannel(channelToDelete)
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "myChannelsToAddSeg" {
            let editChannelView = segue.destination as! AddChannelTableViewController
            
            editChannelView.channelToEdit = sender as? Channel
        }
    }
}
