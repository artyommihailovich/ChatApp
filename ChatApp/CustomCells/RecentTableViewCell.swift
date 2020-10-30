//
//  RecentTableViewCell.swift
//  ChatApp
//
//  Created by Artyom Mihailovich on 10/30/20.
//

import UIKit

class RecentTableViewCell: UITableViewCell {

    //MARK: - IBOutlets
    
    @IBOutlet var avatarImageView: UIImageView!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var lastMessageLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var unreadCounterLabel: UILabel!
    @IBOutlet var unreadCounterBackgroundView: UIView!
    
    
    //MARK: - View life cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        unreadCounterBackgroundView.layer.cornerRadius = unreadCounterBackgroundView.frame.width / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configure(recent: RecentChat) {
        
        // Username
        usernameLabel.text = recent.receiverName
        usernameLabel.adjustsFontSizeToFitWidth = true
        usernameLabel.minimumScaleFactor = 0.9
        
        // Last message
        lastMessageLabel.text = recent.lastMessage
        lastMessageLabel.adjustsFontSizeToFitWidth = true
        lastMessageLabel.numberOfLines = 2
        lastMessageLabel.minimumScaleFactor = 0.9
        
        // Unread counter
        if recent.unreadCounter != 0 {
            self.unreadCounterLabel.text = "\(recent.unreadCounter)"
            self.unreadCounterBackgroundView.isHidden = false
        } else {
            self.unreadCounterBackgroundView.isHidden = true
        }
        
        setAvatar(avatarLink: recent.avatarLink)
        dateLabel.text = timeElapsed(recent.date ?? Date())
        dateLabel.adjustsFontSizeToFitWidth = true
    }
    
    private func setAvatar(avatarLink: String) {
        if avatarLink != "" {
            FileStorage.downloadImage(imageUrl: avatarLink) { (avatarImage) in
                self.avatarImageView.image = avatarImage?.circleMasked
                }
            } else {
                self.avatarImageView.image = UIImage(named: "avatar")?.circleMasked
        }
    }
}

