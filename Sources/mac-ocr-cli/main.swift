//
//  main.swift
//
//
//  Created by Liu Chen on 2022/4/20.
//

import Foundation

func main() -> Int32 {
    guard CommandLine.arguments.count == 2 else {
        print("usage: \(CommandLine.arguments[0]) file")
        return 1
    }

    let recognizer = TextRecognizer(imageFile: CommandLine.arguments[1])
    recognizer.perform()

    if recognizer.error != nil {
        print(recognizer.error!.localizedDescription)
        return 1
    }

    guard let result = recognizer.result() else {
        return 1
    }

    print(result)
    return 0
}

exit(main())
