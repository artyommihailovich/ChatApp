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
        messageInputBar.inputTextView.isImagePasteEnabled = true
        messageInputBar.backgroundView.backgroundColor = .systemBackground
        messageInputBar.inputTextView.backgroundColor = . systemBackground
        
    }
    
    
    //MARK: - Load chats
    
    private func loadChats() {
        let predicate = NSPredicate(format: "chatRoomId = %@", chatId)
        
        allLocalMessages = realm.objects(LocalMessage.self).filter(predicate).sorted(byKeyPath: kDATE, ascending: true)
        
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
    
    
    //MARK: - Actions
    
    func messageSend(text: String?, photo: UIImage?, video: String?, audio: String?, location: String?, audioDuration: Float = 0.0) {
        
        OutgoingMessage.send(chatId: chatId, text: text, photo: photo, video: video, audio: audio, location: location, memberIds: [User.currentId, recepientId])
    }
}
