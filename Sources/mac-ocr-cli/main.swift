//
//  main.swift
//
//
//  Created by Liu Chen on 2022/4/20.
//

import Foundation

if CommandLine.arguments.count < 2 {
    print(TextRecognizeResult.error(code: -1, message: "usage: \(CommandLine.arguments[0]) file").jsonString())
    exit(1)
}

let result = TextRecognizer().perform(file: CommandLine.arguments[1])
print(result.jsonString())
