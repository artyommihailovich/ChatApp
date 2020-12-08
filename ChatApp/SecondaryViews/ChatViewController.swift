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
    
    let currentUser = MKSender(senderId: User.currentId, displayName: User.currentUser!.username)
    let refreshController = UIRefreshControl()
    let micButton = InputBarButtonItem()
    
    var mkMessages: [MKMessage] = []
    var allLocalMessages: Results<LocalMessage>!
    
    let realm = try! Realm()
    
    
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
        configureMessageCollectionView()
        configureMessageInputBar()
        loadChats()
        configureLeftBarButton()
        configureCustomTitle()
        loadChats()
        listenForNewChats()
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
    
    private func configureMessageInputBar() {
        messageInputBar.delegate = self
        
        let attachButton = InputBarButtonItem()
        attachButton.image = UIImage(systemName: "plus.diamond", withConfiguration: UIImage.SymbolConfiguration(weight: .light))
        attachButton.setSize(CGSize(width: 30, height: 30), animated: false)
        attachButton.onTouchUpInside { item in
            print("Attach button pressed!")
        }
        
        micButton.image = UIImage(systemName: "mic", withConfiguration: UIImage.SymbolConfiguration(weight: .light ))
        micButton.setSize(CGSize(width: 30, height: 30 ), animated: false)
        
        // Add gesture recognizer
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
    
    private func insertMessages() {
        
        for message in allLocalMessages {
            insertMessage(message)
        }
    }
    
    private func insertMessage(_ localMessage: LocalMessage) {
        let incoming = IncomingMessage(_collectionView: self)
        
        self.mkMessages.append(incoming.createMessage(localMessage: localMessage)!)
    }
    
    
    private func listenForNewChats() {
        FirebaseMessageListener.shared.listenForNewChats(User.currentId, collectionId: chatId, lastMessageDate: lastMessageDate())
    }
    
    private func checkForOldChats() {
    
        FirebaseMessageListener.shared.checkForOldChats(User.currentId, collectionId: chatId)
    }
    
    
    //MARK: - Actions
    
    func messageSend(text: String?, photo: UIImage?, video: String?, audio: String?, location: String?, audioDuration: Float = 0.0) {
        
        OutgoingMessage.send(chatId: chatId, text: text, photo: photo, video: video, audio: audio, location: location, memberIds: [User.currentId, recepientId])
    }
    
    //Chevron back button
    
    @objc func backButtonPressed() {
        //TODO: Remove listeners
        
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
    //MARK: - Update typing indicator
    
    func updateTypingIndicator(_ show: Bool) {
       // subTitleLabel.text = show ? "Typing..." : ""
    }
    
    
    //MARK: - Helpers
    
    private func lastMessageDate() -> Date {
        let lastMessageDate = allLocalMessages.last?.date ?? Date()
        
        return Calendar.current.date(byAdding: .second, value: 1, to: lastMessageDate) ?? lastMessageDate
    }
    
}
