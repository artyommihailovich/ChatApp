//
//  ChannelTableViewCell.swift
//  ChatApp
//
//  Created by Artyom Mihailovich on 12/19/20.
//

import UIKit

class ChannelTableViewCell: UITableViewCell {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var avatarImageViewOutlet: UIImageView!
    @IBOutlet weak var nameLabelOutlet: UILabel!
    @IBOutlet weak var aboutLabelOutlet: UILabel!
    @IBOutlet weak var memberCountLabelOutlet: UILabel!
    @IBOutlet weak var lastMessageDateLabelOutlet: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }

    func configure(channel: Channel) {
        nameLabelOutlet.text = channel.name
        aboutLabelOutlet.text = channel.aboutChannel
        memberCountLabelOutlet.text = "\(channel.memberIds.count) \(String(describing: UIImage(systemName: "person.2", withConfiguration: UIImage.SymbolConfiguration(weight: .light))))"
        lastMessageDateLabelOutlet.text = timeElapsed(channel.lastMessageDate ?? Date())
        lastMessageDateLabelOutlet.adjustsFontSizeToFitWidth = true
        setAvatar(avatarLink: channel.avatarLink)
    }
    
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
