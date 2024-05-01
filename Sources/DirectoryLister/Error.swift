// Created by Ahmet Karalar for  in 2024
// Using Swift 5.0


import Foundation
import AlfredJSONEncoder

struct Error {
    var text: String
}

extension Error: AlfredListItemConvertible {
    var asAlfredListItem: AlfredListItem { AlfredListItem(error: self) }
}

extension AlfredList {
    mutating func addError(_ text: String) {
        let item = AlfredListItem(error: Error(text: text))
        items.append(item)
    }
}

extension AlfredListItem {
    init(error: Error) {
        self.init(
            title: error.text,
            arguments: nil,
            icon: Icon(path: "./error.png"),
            isValid: false,
            skipKnowledge: true
        )
    }
}
