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

    }
}
