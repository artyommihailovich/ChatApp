//
//  UserTableViewCell.swift
//  ChatApp
//
//  Created by Artyom Mihailovich on 10/23/20.
//

import UIKit

class UserTableViewCell: UITableViewCell {

    //MARK: - IBOutlets
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    
    //MARK: - View life cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureCell(user: User){
        usernameLabel.text = user.username
        statusLabel.text = user.status
        setAvatar(avatarLink: user.avatarLink)
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
