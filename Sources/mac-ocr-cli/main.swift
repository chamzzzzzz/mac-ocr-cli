//
//  main.swift
//
//
//  Created by Liu Chen on 2022/4/20.
//

import Foundation

if CommandLine.arguments.count < 2 {
    print("usage: \(CommandLine.arguments[0]) imageFile")
    exit(1)
}

let recognizer = TextRecognizer(imageFile: CommandLine.arguments[1])
recognizer.perform()
