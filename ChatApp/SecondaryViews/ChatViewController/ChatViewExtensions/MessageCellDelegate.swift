//
//  MessageCellDelegate.swift
//  ChatApp
//
//  Created by Artyom Mihailovich on 11/15/20.
//

import Foundation
import MessageKit
import AVFoundation
import AVKit
import SKPhotoBrowser

extension ChatViewController: MessageCellDelegate {
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        
        if let indexPath = messagesCollectionView.indexPath(for: cell) {
            let mkMessage = mkMessages[indexPath.section]
            
            if mkMessage.photoItem != nil && mkMessage.photoItem!.image != nil {
                var images = [SKPhoto]()
                let photo = SKPhoto.photoWithImage(mkMessage.photoItem!.image!)
                
                images.append(photo)
                
                let browser = SKPhotoBrowser(photos: images)
                
                browser.initializePageIndex(0)
                present(browser, animated: true, completion: nil)
            }
            
            if mkMessage.videoItem != nil && mkMessage.videoItem!.url != nil {
                
                let player = AVPlayer(url: mkMessage.videoItem!.url!)
                let moviePlayer = AVPlayerViewController()
                
                let session = AVAudioSession.sharedInstance()
                
                try! session.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
                
                moviePlayer.player = player
                
                present(moviePlayer, animated: true) {
                    moviePlayer.player!.play()
                }
            }
        }
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        
        if let indexPath = messagesCollectionView.indexPath(for: cell) {
            let mkMessage = mkMessages[indexPath.section]
            
            if mkMessage.locationitem != nil {
                let mapView = MapViewController()
                mapView.location = mkMessage.locationitem?.location

                navigationController?.pushViewController(mapView, animated: true)
            }
        }
    }
    
    func didTapPlayButton(in cell: AudioMessageCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell),
            let message = messagesCollectionView.messagesDataSource?.messageForItem(at: indexPath, in: messagesCollectionView) else {
                print("Failed to identify message when audio cell receive tap gesture")
                return
        }
        guard audioController.state != .stopped else {
            audioController.playSound(for: message, in: cell)
            return
        }
        if audioController.playingMessage?.messageId == message.messageId {
    
            if audioController.state == .playing {
                audioController.pauseSound(for: message, in: cell)
            } else {
                
                audioController.resumeSound()
            }
        } else {

            audioController.stopAnyOngoingPlaying()
            audioController.playSound(for: message, in: cell)
        }
    }
}

