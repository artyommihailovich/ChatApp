//
//  ChannelTableViewController.swift
//  ChatApp
//
//  Created by Artyom Mihailovich on 12/19/20.
//

import UIKit

protocol ChannelDetailTableViewControllerDelegate {
    func didClickFollow()
}

class ChannelDetailTableViewController: UITableViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var avatarImageViewOutlet: UIImageView!
    @IBOutlet weak var nameLabelOutlet: UILabel!
    @IBOutlet weak var membersLabelOutlet: UILabel!
    @IBOutlet weak var aboutTextViewOutlet: UITextView!
    
    
    //MARK: - Variables
    
    var channel: Channel!
    var delegate: ChannelDetailTableViewControllerDelegate?
    
    
    //MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        
        configureRightBarButtonItem()
        configureBackButton()
        
        showChannelData()
    }
    
    
    //MARK: - Configure
    
    private func showChannelData() {
        self.title = channel.name
        nameLabelOutlet.text = channel.name
        membersLabelOutlet.text = "\(channel.memberIds.count) ⚇"
        aboutTextViewOutlet.text = channel.aboutChannel
        setAvatar(avatarLink: channel.avatarLink)
    }
    
    private func configureRightBarButtonItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Follow", style: .plain, target: self, action: #selector(followToChannel))
        navigationItem.rightBarButtonItem?.tintColor = .systemOrange
    }
    
    private func configureBackButton() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(weight: .light))?.withTintColor(.systemOrange, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(backButtonPressed))
    }
    
    
    //MARK: - Actions
    
    @objc func followToChannel() {
        channel.memberIds.append(User.currentId)
        FirebaseChannelListener.shared.saveChannel(channel)
        delegate?.didClickFollow()
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc
    func backButtonPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //MARK: - Avatar
    
    private func setAvatar(avatarLink: String) {
        
        if avatarLink != "" {
            FileStorage.downloadImage(imageUrl: avatarLink) { (avatarImage) in
                
                DispatchQueue.main.async {
                    self.avatarImageViewOutlet.image = avatarImage != nil ? avatarImage?.circleMasked : UIImage(named: "avatar")
                }
            }
        } else {
            self.avatarImageViewOutlet.image = UIImage(named: "avatar")
        }
    }
}
