//
//  AudioMessage.swift
//  ChatApp
//
//  Created by Artyom Mihailovich on 12/18/20.
//

import Foundation
import MessageKit

class AudioMessage: NSObject, AudioItem {
    
    var url: URL
    var duration: Float
    var size: CGSize
    
    init(duration: Float) {
        self.url = URL(fileURLWithPath: "")
        self.size = CGSize(width: 150, height: 30)
        self.duration = duration
    }
}

