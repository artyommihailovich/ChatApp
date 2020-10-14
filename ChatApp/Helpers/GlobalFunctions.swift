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
