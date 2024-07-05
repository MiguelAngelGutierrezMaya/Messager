//
//  GlobalFunctions.swift
//  Messenger
//
//  Created by Miguel Angel Gutierrez Maya on 25/03/24.
//

import Foundation

func fileNameFrom(fileUrl: String) -> String {
    let firstSeparation = fileUrl.components(separatedBy: "_").last
    let secondSeparation = firstSeparation?.components(separatedBy: "?").first
    let name = secondSeparation?.components(separatedBy: ".").first
    return name ?? ""
}
