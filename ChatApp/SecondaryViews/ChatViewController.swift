//
//  ChatViewController.swift
//  ChatApp
//
//  Created by Artyom Mihailovich on 11/5/20.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import Gallery
import RealmSwift

class ChatViewController: MessagesViewController {

    //MARK: - Views
    
    let leftBarButtonView: UIView = {
        return UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
    }()
    
    let titleLabel: UILabel = {
        let title = UILabel(frame: CGRect(x: 5, y: 0, width: 180, height: 25))
        title.textAlignment = .left
        title.font = .systemFont(ofSize: 15, weight: .medium)
        title.adjustsFontSizeToFitWidth = true
        
        return title
    }()
    
    let subTitleLabel: UILabel = {
        let subTitle = UILabel(frame: CGRect(x: 5, y: 22, width: 180, height: 20))
        subTitle.textAlignment = .left
        subTitle.font = .systemFont(ofSize: 12, weight: .medium)
        //subTitle.tintColor = .systemGray4
        subTitle.adjustsFontSizeToFitWidth = true
        
        return subTitle
    }()
    
    
    //MARK: - Variables
    
    private var chatId = ""
    private var recepientId = ""
    private var recepientName = ""
    
    open lazy var audioController = BasicAudioController(messageCollectionView: messagesCollectionView)
    
    let currentUser = MKSender(senderId: User.currentId, displayName: User.currentUser!.username)
    let refreshController = UIRefreshControl()
    let micButton = InputBarButtonItem()
    
    var mkMessages: [MKMessage] = []
    var allLocalMessages: Results<LocalMessage>!
    
    let realm = try! Realm()
    
    var displayingMessagesCount = 0
    var maxMessageNumber = 0
    var minMessageNumber = 0
    
    var typingCounter = 0
    
    var gallery: GalleryController!
    var longPressGesture: UILongPressGestureRecognizer!
    
    var audioFileName = ""
    var audioDuration: Date!
    
    
    //MARK: - Listeners
    
    var notificationToken: NotificationToken?
    
    
    //MARK: - Inits
    
    init(chatId: String, recepientId: String, recepientName: String) {
        super.init(nibName: nil, bundle: nil)
        
        self.chatId = chatId
        self.recepientId = recepientId
        self.recepientName = recepientName
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    //MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        
        createTypingObserver()
        configureMessageCollectionView()
        configureGestureRecognizer()
        configureMessageInputBar()
        configureLeftBarButton()
        configureCustomTitle()
        loadChats()
        listenForNewChats()
        listenForReadStatusChange()
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
    
    
    //MARK: - Configuration
    
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
        messageInputBar.delegate = self
        
        let attachButton = InputBarButtonItem()
        attachButton.image = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(weight: .light))
        attachButton.setSize(CGSize(width: 30, height: 30), animated: false)
        attachButton.onTouchUpInside { item in
            self.actionAttachMessage()
            
        }
        
        micButton.image = UIImage(systemName: "mic", withConfiguration: UIImage.SymbolConfiguration(weight: .light ))
        micButton.setSize(CGSize(width: 30, height: 30 ), animated: false)
        micButton.addGestureRecognizer(longPressGesture)
        
        messageInputBar.setStackViewItems([attachButton], forStack: .left, animated: false)
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        updatedMicButtonStatus(show: true)
        messageInputBar.inputTextView.isImagePasteEnabled = true
        messageInputBar.backgroundView.backgroundColor = .systemBackground
        messageInputBar.inputTextView.backgroundColor = . systemBackground
    }
    
    // Update mic button
    
    func updatedMicButtonStatus(show: Bool) {
        
        if show {
            messageInputBar.setStackViewItems([micButton], forStack: .right, animated: false)
            messageInputBar.setRightStackViewWidthConstant(to: 30, animated: false)
        } else {
            messageInputBar.setStackViewItems([messageInputBar.sendButton], forStack: .right, animated: false)
            messageInputBar.setRightStackViewWidthConstant(to: 50, animated: false)
        }
    }
    
    
    //MARK: - Configure left bar button
    
    private func configureLeftBarButton() {
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(weight: .light))?.withTintColor(.systemOrange, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(backButtonPressed))]
    }
    
    private func configureCustomTitle() {
        leftBarButtonView.addSubview(titleLabel)
        leftBarButtonView.addSubview(subTitleLabel)
        
        let leftBarButton = UIBarButtonItem(customView: leftBarButtonView)
        
        self.navigationItem.leftBarButtonItems?.append(leftBarButton)
        
        titleLabel.text = recepientName
        
    }
    
    
    //MARK: - Load chats
    
    private func loadChats() {
        let predicate = NSPredicate(format: "chatRoomId = %@", chatId)
        
        allLocalMessages = realm.objects(LocalMessage.self).filter(predicate).sorted(byKeyPath: kDATE, ascending: true)
        
        if allLocalMessages.isEmpty {
            checkForOldChats()
        }
        
        notificationToken = allLocalMessages.observe({ (changes: RealmCollectionChange) in
            
            switch changes {
            case .initial:
                
                self.insertMessages()
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToBottom(animated: true )
                
            case .update(_, _,  let insertions, _):
                
                for index in insertions {
                    self.insertMessage(self.allLocalMessages[index])
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToBottom(animated: false)
                }
                
            case .error(let error):
                print("Error on new insertion ", error.localizedDescription)
            }
        })
    }
    
    
    //MARK: - Insert messages
    
    private func listenForReadStatusChange() {
        FirebaseMessageListener.shared.listenForReadStatusChange(User.currentId, collectionId: chatId) { (updatedMessage) in
            
            if updatedMessage.status != kSENT {
                self.updateMessage(updatedMessage)
            }
        }
    }
    
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
        
        if localMessage.senderId != User.currentId {
            markMessageAsRead(localMessage)
        }
        
        let incoming = IncomingMessage(_collectionView: self)
        
        self.mkMessages.append(incoming.createMessage(localMessage: localMessage)!)
        displayingMessagesCount += 1
    }
    
    
    private func listenForNewChats() {
        FirebaseMessageListener.shared.listenForNewChats(User.currentId, collectionId: chatId, lastMessageDate: lastMessageDate())
    }
    
    private func checkForOldChats() {
    
        FirebaseMessageListener.shared.checkForOldChats(User.currentId, collectionId: chatId)
    }
    
    private func loadMoreMessages(maxNumber: Int, minNumber: Int){
        maxMessageNumber = minNumber - 1
        minMessageNumber = maxMessageNumber - kNUMBEROFMESSAGES
        
        if minMessageNumber < 0 {
            minMessageNumber = 0
        }
        
        for i in (minMessageNumber...maxMessageNumber).reversed() {
            insertOlderMessages(allLocalMessages[i])
        }
    }
    
    private func insertOlderMessages(_ localMessage: LocalMessage) {
        let incoming = IncomingMessage(_collectionView: self)
        self.mkMessages.insert(incoming.createMessage(localMessage: localMessage)!, at: 0)
        displayingMessagesCount += 1
    }
    
    private func markMessageAsRead(_ localMessage: LocalMessage) {
        
        if localMessage.senderId != User.currentId && localMessage.status != kREAD {
            FirebaseMessageListener.shared.updateMessageInFirebase(localMessage, memberIds: [User.currentId, recepientId])
        }
    }
    
    //MARK: - Actions
    
    func messageSend(text: String?, photo: UIImage?, video: Video?, audio: String?, location: String?, audioDuration: Float = 0.0) {
        
        OutgoingMessage.send(chatId: chatId, text: text, photo: photo, video: video, audio: audio, audioDuration: audioDuration,  location: location, memberIds: [User.currentId, recepientId])
    }
    
    //Chevron back button
    
    @objc func backButtonPressed() {
        FirebaseRecentListener.shared.resetRecentCounter(chatRoomId: chatId)
        removeListeners()
        
        self.navigationController?.popToRootViewController(animated: true)
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
    
    
    //MARK: - Update typing indicator
    
    func createTypingObserver() {
        FirebaseTypingListener.shared.createTypingObserver(chatRoomId: chatId) { (isTyping) in
            
            DispatchQueue.main.async {
                self.updateTypingIndicator(isTyping)
            }
        }
    }
    
    func typingIndicatorUpdate() {
        typingCounter += 1

        FirebaseTypingListener.saveTypingCounter(typing: true, chatRoomId: chatId)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.typingCounterStop()
        }
    }
    
    func typingCounterStop() {
        typingCounter -= 1
        
        if typingCounter == 0 {
            FirebaseTypingListener.saveTypingCounter(typing: false, chatRoomId: chatId)
        }
    }
    
    func updateTypingIndicator(_ show: Bool) {
        subTitleLabel.text = show ? "Typing..." : ""
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
    
    
    //MARK: - Update read message status
    
    private func updateMessage(_ localMessage: LocalMessage) {
        
        for index in 0 ..< mkMessages.count {
            let tempMessage = mkMessages[index]
            
            if localMessage.id == tempMessage.messageId {
                mkMessages[index].status = localMessage.status
                mkMessages[index].readDate = localMessage.readDate
                
                RealmManager.shared.saveToRealm(localMessage)
                
                if mkMessages[index].status == kREAD {
                    self.messagesCollectionView.reloadData()
                }
            }
        }
    }
    
    
    //MARK: - Helpers
    
    private func removeListeners() {
        FirebaseTypingListener.shared.removeTypingListener()
        FirebaseMessageListener.shared.removeListeners()
    }
    
    private func lastMessageDate() -> Date {
        let lastMessageDate = allLocalMessages.last?.date ?? Date()
        
        return Calendar.current.date(byAdding: .second, value: 1, to: lastMessageDate) ?? lastMessageDate
    }
    
    
    //MARK: - Gallery part

    private func showImageGallery(camera: Bool) {
        gallery = GalleryController()
        gallery.delegate = self
        
        Config.tabsToShow = camera ? [.cameraTab] : [.imageTab,.videoTab]
        Config.Camera.imageLimit = 1
        Config.initialTab = .imageTab
        Config.VideoEditor.maximumDuration = 45
        
        self.present(gallery, animated: true, completion: nil)
        
    }
    
    
    //MARK: - Audio messages
    
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


    //MARK: - Gallery extension

    extension ChatViewController: GalleryControllerDelegate {
    
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
