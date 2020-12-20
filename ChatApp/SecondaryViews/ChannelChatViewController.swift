//
//  ChannelChatViewController.swift
//  ChatApp
//
//  Created by Artyom Mihailovich on 12/20/20.
//

import Foundation
import MessageKit
import InputBarAccessoryView
import Gallery
import RealmSwift

class ChannelChatViewController: MessagesViewController {

    //MARK: - Vars
    
    private var chatId = ""
    private var recipientId = ""
    private var recipientName = ""
    
    var channel: Channel!
    
    open lazy var audioController = BasicAudioController(messageCollectionView: messagesCollectionView)
    
    let currentUser = MKSender(senderId: User.currentId, displayName: User.currentUser!.username)
    
    let refreshController = UIRefreshControl()
    var gallery: GalleryController!

    var displayingMessagesCount = 0
    var maxMessageNumber = 0
    var minMessageNumber = 0
    
    var mkMessages: [MKMessage] = []
    var allLocalMessages: Results<LocalMessage>!
    
    let realm = try! Realm()
    
    let micButton = InputBarButtonItem()
    
    var longPressGesture: UILongPressGestureRecognizer!
    var audioFileName = ""
    var audioDuration: Date!

    
    //MARK: - Listeners
    
    var notificationToken: NotificationToken?
    
    
    //MARK: - Inits
    
    init(channel: Channel) {
        
        super.init(nibName: nil, bundle: nil)
        
        self.chatId = channel.id
        self.recipientId = channel.id
        self.recipientName = channel.name
        self.channel = channel
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    //MARK: - View Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never
                
        configureLeftBarButton()
        configureCustomTitle()

        configureMessageCollectionView()
        configureGestureRecognizer()
        
        configureMessageInputBar()

        loadChats()
        listenForNewChats()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        FirebaseRecentListener.shared.resetRecentCounter(chatRoomId: chatId)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        FirebaseRecentListener.shared.resetRecentCounter(chatRoomId: chatId)
        audioController.stopAnyOngoingPlaying()
    }
    
    
    //MARK: - Configurations
    
    private func configureMessageCollectionView() {
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        
        scrollsToBottomOnKeyboardBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
        
        messagesCollectionView.refreshControl = refreshController
    }

    private func configureGestureRecognizer() {
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(recordAudio))
        longPressGesture.minimumPressDuration = 0.5
        longPressGesture.delaysTouchesBegan = true
    }
    
    private func configureMessageInputBar() {
        
        messageInputBar.isHidden = channel.adminId != User.currentId
        
        messageInputBar.delegate = self
        
        let attachButton = InputBarButtonItem()
        attachButton.image = UIImage(systemName: "plus",  withConfiguration: UIImage.SymbolConfiguration(weight: .light ))
        
        attachButton.setSize(CGSize(width: 30, height: 30), animated: false)
        
        attachButton.onTouchUpInside {
            item in
            
            self.actionAttachMessage()
        }
        
        micButton.image = UIImage(systemName: "mic", withConfiguration: UIImage.SymbolConfiguration(weight: .light ))
        micButton.setSize(CGSize(width: 30, height: 30 ), animated: false)
        micButton.addGestureRecognizer(longPressGesture)
        
        messageInputBar.setStackViewItems([attachButton], forStack: .left, animated: false)
        
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        
        updateMicButtonStatus(show: true)
        
        messageInputBar.inputTextView.isImagePasteEnabled = false
        messageInputBar.backgroundView.backgroundColor = .systemBackground
        messageInputBar.inputTextView.backgroundColor = .systemBackground
    }
    
    func updateMicButtonStatus(show: Bool) {
        
        if show {
            messageInputBar.setStackViewItems([micButton], forStack: .right, animated: false)
            messageInputBar.setRightStackViewWidthConstant(to: 30, animated: false)
        } else {
            messageInputBar.setStackViewItems([messageInputBar.sendButton], forStack: .right, animated: false)
            messageInputBar.setRightStackViewWidthConstant(to: 55, animated: false)
        }
    }
    
    private func configureLeftBarButton() {
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(weight: .light))?.withTintColor(.systemOrange, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(backButtonPressed))]
    }
    
    private func configureCustomTitle() {
        
        self.title = channel.name
    }
    
    
    //MARK: - Load Chats
    
    private func loadChats() {
                
        let predicate = NSPredicate(format: "chatRoomId = %@", chatId)

        allLocalMessages = realm.objects(LocalMessage.self).filter(predicate).sorted(byKeyPath: kDATE, ascending: true)

        if allLocalMessages.isEmpty {
            checkForOldChats()
        }
        
        notificationToken = allLocalMessages.observe({ (changes: RealmCollectionChange) in

            //updated message
            switch changes {
            case .initial:
                self.insertMessages()
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToBottom(animated: true)

            case .update(_, _ , let insertions, _):

                for index in insertions {

                    self.insertMessage(self.allLocalMessages[index])
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToBottom(animated: false)
                }

            case .error(let error):
                print("Error on new insertion", error.localizedDescription)
            }
        })
    }

    private func listenForNewChats() {
        FirebaseMessageListener.shared.listenForNewChats(User.currentId, collectionId: chatId, lastMessageDate: lastMessageDate())
    }
    
    private func checkForOldChats() {
        FirebaseMessageListener.shared.checkForOldChats(User.currentId, collectionId: chatId)
    }
    
    
    //MARK: - Insert Messages
    
    private func insertMessages() {

        maxMessageNumber = allLocalMessages.count - displayingMessagesCount
        minMessageNumber = maxMessageNumber - kNUMBEROFMESSAGES
        
        if minMessageNumber < 0 {
            minMessageNumber = 0
        }
        
        for i in minMessageNumber ..< maxMessageNumber {
            insertMessage(allLocalMessages[i])
        }
    }
    
    private func insertMessage(_ localMessage: LocalMessage) {

        let incoming = IncomingMessage(_collectionView: self)
        self.mkMessages.append(incoming.createMessage(localMessage: localMessage)!)
        displayingMessagesCount += 1
    }

    private func loadMoreMessages(maxNumber: Int, minNumber: Int) {
        
        maxMessageNumber = minNumber - 1
        minMessageNumber = maxMessageNumber - kNUMBEROFMESSAGES

        if minMessageNumber < 0 {
            minMessageNumber = 0
        }
        
        
        for i in (minMessageNumber ... maxMessageNumber).reversed() {
            insertOlderMessage(allLocalMessages[i])
        }
        
    }
    
    private func insertOlderMessage(_ localMessage: LocalMessage) {

        let incoming = IncomingMessage(_collectionView: self)
        self.mkMessages.insert(incoming.createMessage(localMessage: localMessage)!, at: 0)
        displayingMessagesCount += 1
    }


    //MARK: - Actions
    
    @objc func backButtonPressed() {
        FirebaseRecentListener.shared.resetRecentCounter(chatRoomId: chatId)
        removeListeners()
        self.navigationController?.popViewController(animated: true)
    }

    func messageSend(text: String?, photo: UIImage?, video: Video?, audio: String?, location: String?, audioDuration: Float = 0.0) {
        
        OutgoingMessage.sendChannel(channel: channel, text: text, photo: photo, video: video, audio: audio, audioDuration: audioDuration, location: location)
    }

    
    private func actionAttachMessage() {
        
        messageInputBar.inputTextView.resignFirstResponder()
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
        let takePhotoOrVideo = UIAlertAction(title: "Camera", style: .default) { (alert) in
            self.showImageGallery(camera: true)
        }
        
        let sharePhotoOrVideo = UIAlertAction(title: "Library", style: .default) { (alert) in
            self.showImageGallery(camera: false)
        }
        
        let shareLocation = UIAlertAction(title: "Share location", style: .default) { (alert) in
            
            if let _ = LocationManager.shared.currentLocation {
                self.messageSend(text: nil, photo: nil, video: nil, audio: nil, location: kLOCATION)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        takePhotoOrVideo.setValue(UIImage(systemName: "camera"), forKey: "image")
        sharePhotoOrVideo.setValue(UIImage(systemName: "photo.fill"), forKey: "image")
        shareLocation.setValue(UIImage(systemName: "map"), forKey: "image")
        
        optionMenu.addAction(takePhotoOrVideo)
        optionMenu.addAction(sharePhotoOrVideo)
        optionMenu.addAction(shareLocation)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    
    //MARK: - UIScrollViewDelegate
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if refreshController.isRefreshing {
            
            if displayingMessagesCount < allLocalMessages.count {
                self.loadMoreMessages(maxNumber: maxMessageNumber, minNumber: minMessageNumber)
                messagesCollectionView.reloadDataAndKeepOffset()
            }
            
            refreshController.endRefreshing()
        }
    }

    
    //MARK: - Helpers
    
    private func removeListeners() {
        FirebaseMessageListener.shared.removeListeners()
    }
    
    private func lastMessageDate() -> Date {
        
        let lastMessageDate = allLocalMessages.last?.date ?? Date()
        return Calendar.current.date(byAdding: .second, value: 1, to: lastMessageDate) ?? lastMessageDate
    }


    //MARK: - Gallery
    
    private func showImageGallery(camera: Bool) {
        
        gallery = GalleryController()
        gallery.delegate = self
        
        Config.tabsToShow = camera ? [.cameraTab] : [.imageTab, .videoTab]
        Config.Camera.imageLimit = 1
        Config.initialTab = .imageTab
        Config.VideoEditor.maximumDuration = 30
        
        self.present(gallery, animated: true, completion: nil)
    }
    
    
    //MARK: - AudioMessages
    
    @objc func recordAudio() {
        
        switch longPressGesture.state {
        case .began:
            audioDuration = Date()
            audioFileName = Date().stringDate()
            AudioRecorder.shared.startRecording(fileName: audioFileName)
        case .ended:
            
            AudioRecorder.shared.finishRecording()
            
            if fileExistAtPath(path: audioFileName + ".m4a") {
                
                let audioDur = audioDuration.timeInterval(of: .second, from: Date())
                
                messageSend(text: nil, photo: nil, video: nil, audio: audioFileName, location: nil, audioDuration: audioDur )
            } else {
                print("no audio file")
            }
            
            audioFileName = ""
            
        @unknown default:
            print("unknown")
        }
    }
}


    //MARK: - Extensions

extension ChannelChatViewController : GalleryControllerDelegate {
    
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        
        if images.count > 0 {
            images.first!.resolve { (image) in
                
                self.messageSend(text: nil, photo: image, video: nil, audio: nil, location: nil)
            }
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        
        self.messageSend(text: nil, photo: nil, video: video, audio: nil, location: nil)
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
