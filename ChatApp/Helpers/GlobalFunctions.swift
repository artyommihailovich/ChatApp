//
//  GlobalFunctions.swift
//  ChatApp
//
//  Created by Artyom Mihailovich on 10/14/20.
//

import Foundation

func fileNameFrom(fileUrl: String) -> String {
    // That's func for geting short name of jpeg URL adress
    return ((fileUrl.components(separatedBy: "_").last)!.components(separatedBy: "?").first!).components(separatedBy: ".").first!
}

func timeElapsed(_ date: Date) -> String {
    let seconds = Date().timeIntervalSince(date)
    var elapsed = ""
    
    if seconds < 60 {
        
        elapsed = "Just now"
    } else if seconds < 60 * 60 {
        let minutes = Int(seconds / 60)
        let minText = minutes > 1 ? "mins" : "min"
        
        elapsed = "\(minutes) \(minText)"
    } else if seconds < 24 * 60 * 60 {
        let hours = Int(seconds / 60 * 60 )
        let hourseText = hours > 1 ? "hours" : "hour"
        
        elapsed = "\(hourseText) \(hourseText)"
    } else {
        
        elapsed = date.longDate()
    }
    return elapsed
}
