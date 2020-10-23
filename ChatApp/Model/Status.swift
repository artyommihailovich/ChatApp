//
//  Status.swift
//  ChatApp
//
//  Created by Artyom Mihailovich on 10/23/20.
//

import Foundation

enum Status: String {
    case Availible = "Availible"
    case InYogaClass = "In yoga class"
    case Busy = "Busy"
    case AtTheCode = "At the code 👨🏼‍💻"
    case AtTheMovies = "At the Movies"
    case BatteryAboutToDie = "Battery about to die"
    case CanNotTalk = "Can't talk"
    case NotAvailible = "Not availible"
    case AtTheGym = "At the gym"
    case Sleeping = "Sleeping"
    case UrgentCallsOnly = "Urgent calls only"
    case LeftToSkate = "Left to skate"
    case WaitingForBerningMan = "Waiting for Berning Man"
    case ShareYumYum = "Share yum yum"
    
    static var array: [Status] {
        var a: [Status] = []
        
        switch Status.Availible {
        case .Availible:
            a.append(.Availible); fallthrough
        case .Availible:
            a.append(.Availible); fallthrough
        case .InYogaClass:
            a.append(.InYogaClass); fallthrough
        case .Busy:
            a.append(.Busy); fallthrough
        case .AtTheCode:
            a.append(.AtTheCode); fallthrough
        case .AtTheMovies:
            a.append(.AtTheMovies); fallthrough
        case .BatteryAboutToDie:
            a.append(.BatteryAboutToDie); fallthrough
        case .CanNotTalk:
            a.append(.CanNotTalk); fallthrough
        case .NotAvailible:
            a.append(.NotAvailible); fallthrough
        case .AtTheGym:
            a.append(.AtTheGym); fallthrough
        case .Sleeping:
            a.append(.Sleeping); fallthrough
        case .UrgentCallsOnly:
            a.append(.UrgentCallsOnly); fallthrough
        case .LeftToSkate:
            a.append(.LeftToSkate); fallthrough
        case .WaitingForBerningMan:
            a.append(.WaitingForBerningMan); fallthrough
        case .ShareYumYum:
            a.append(.ShareYumYum); 
            
            return a
        }
    }
}
