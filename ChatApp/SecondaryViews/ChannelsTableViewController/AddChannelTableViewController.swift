//
//  AddChannelTableViewController.swift
//  ChatApp
//
//  Created by Artyom Mihailovich on 12/19/20.
//

import UIKit
import Gallery
import ProgressHUD

class AddChannelTableViewController: UITableViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var avatarImageviewOutlet: UIImageView!
    @IBOutlet weak var nameTextFieldOutlet: UITextField!
    @IBOutlet weak var aboutTextViewOtlet: UITextView!
    
    
    //MARK: - Variables
    
    var gallery: GalleryController!
    var tapGesture = UITapGestureRecognizer()
    var avatarLink = ""
    
    var channelId = UUID().uuidString
    
    var channelToEdit: Channel?
    
    //MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        navigationItem.largeTitleDisplayMode = .never
        
        configureGestureRecognizer()
        configureLeftBarButton()
        
        if channelToEdit != nil {
            configureEditingView()
        }
    }

    
    //MARK: - IBActions
    
    @IBAction func savebuttonPressd(_ sender: Any) {
        
        if nameTextFieldOutlet.text != "" {
            channelToEdit != nil ? editChannel() : saveChannel()
        } else {
            ProgressHUD.showError("Channel name is empty!")
        }
    }
    
    
    //MARK: - Target actions
    
    @objc
    func avatarImageTap() {
       showGallery()
    }
    
    @objc
    func backButtonPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //MARK: - Configuration
    
    private func configureGestureRecognizer() {
        
        tapGesture.addTarget(self, action: #selector(avatarImageTap))
        
        avatarImageviewOutlet.isUserInteractionEnabled = true
        avatarImageviewOutlet.addGestureRecognizer(tapGesture)
    }
    
    private func configureLeftBarButton() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(weight: .light))?.withTintColor(.systemOrange, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(backButtonPressed))
    }
    
    private func configureEditingView() {
        self.title = "Editing channel"
        self.nameTextFieldOutlet.text = channelToEdit!.name
        self.channelId = channelToEdit!.id
        self.aboutTextViewOtlet.text = channelToEdit!.aboutChannel
        self.avatarLink = channelToEdit!.avatarLink
        
        setAvatar(avatarLink: channelToEdit!.avatarLink)
    }
    
    
    //MARK: - Save channel
    
    private func saveChannel() {
        let channel = Channel(id: channelId, name: nameTextFieldOutlet.text!, adminId: User.currentId, memberIds: [User.currentId], avatarLink: avatarLink, aboutChannel: aboutTextViewOtlet.text)
        
        FirebaseChannelListener.shared.saveChannel(channel)
        
        self.navigationController?.popViewController(animated: true)
    }
    
    private func editChannel() {
        
        channelToEdit!.name = nameTextFieldOutlet.text!
        channelToEdit?.aboutChannel = aboutTextViewOtlet.text
        channelToEdit?.avatarLink = avatarLink

        FirebaseChannelListener.shared.saveChannel(channelToEdit!)
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //MARK: - Gallery
    
    private func showGallery(){
        self.gallery = GalleryController()
        self.gallery.delegate = self
        
        Config.tabsToShow = [.imageTab, .cameraTab]
        Config.Camera.imageLimit = 1
        Config.initialTab = .imageTab
        
        present(gallery, animated: true, completion: nil)
    }
    
    
    //MARK: - Avatars
    
    private func uploadAvatarImage(_ image: UIImage) {
        
        let fileDirectory = "Avatars/" + "_\(channelId)" + ".jpg"
        
        FileStorage.uploadImage(image, directory: fileDirectory) { (avatarLink) in
            
            self.avatarLink = avatarLink ?? ""
            
            FileStorage.saveFileLocally(fileData: image.jpegData(compressionQuality: 0.8)! as NSData, fileName: self.channelId)
        }
    }
    
    private func setAvatar(avatarLink: String) {
        
        if avatarLink != "" {
            FileStorage.downloadImage(imageUrl: avatarLink) { (avatarImage) in
                
                DispatchQueue.main.async {
                    self.avatarImageviewOutlet.image = avatarImage?.circleMasked
                }
            }
        } else {
            
            self.avatarImageviewOutlet.image = UIImage(named: "avatar")
        }
    }
}


    //MARK: - Extension

extension AddChannelTableViewController: GalleryControllerDelegate {
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        
        if images.count > 0 {
            images.first!.resolve { (icon) in
                
                if icon != nil {
                    self.uploadAvatarImage(icon!)
                    self.avatarImageviewOutlet.image = icon!.circleMasked
                } else {
                    ProgressHUD.showFailed("Could not select image!")
                }
            }
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
}
