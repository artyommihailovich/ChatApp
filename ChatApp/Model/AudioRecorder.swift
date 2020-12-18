//
//  AudioRecorder.swift
//  ChatApp
//
//  Created by Artyom Mihailovich on 12/18/20.
//

import Foundation
import AVFoundation

class AudioRecorder: NSObject, AVAudioRecorderDelegate {
    
    //MARK: - Singleton
    
    static let shared = AudioRecorder()
    
    private override init() {
        super.init()
        
        checkForRecordPermission()
    }
    
    
    //MARK: - Variables
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var isRecordingGranted: Bool!

    
    //MARK: - Check for record permission
    
    func checkForRecordPermission() {
        
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            isRecordingGranted = true
            break
        case .denied:
            isRecordingGranted = false
            break
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { isAllowed in
                self.isRecordingGranted = isAllowed
            }
        default:
            break
        }
    }
    
    
    //MARK: - Recorder settings
    
    func setupRecording() {
        if isRecordingGranted {
            recordingSession = AVAudioSession.sharedInstance()
            
            do {
                try recordingSession.setCategory(.playAndRecord, mode: .default)
                try recordingSession.setActive(true)
            } catch  {
                print("Error! setting up audio recorder", error.localizedDescription)
            }
        }
    }
    
    func startRecording(fileName: String) {
        let audioFileName = getDocumentsURL().appendingPathComponent(fileName + ".m4a", isDirectory: false)
        
        let settings = [ AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                         AVSampleRateKey: 12000,
                         AVNumberOfChannelsKey: 1,
                         AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                        ]
       
        do {
            audioRecorder = try AVAudioRecorder(url: audioFileName, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
        } catch  {
            print("Error recording audio file", error.localizedDescription)
            finishRecording()
        }
    }
    
    func finishRecording() {
        if audioRecorder != nil {
            audioRecorder.stop()
            audioRecorder = nil
        }
    }
}
