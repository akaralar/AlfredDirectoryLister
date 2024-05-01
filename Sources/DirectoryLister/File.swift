// Created by Ahmet Karalar for  in 2024
// Using Swift 5.0


import Foundation
import AlfredJSONEncoder

struct File {
    var path: String
    var name: String
    var addedDate: Date

    init(inputDir: InputDirectory) {
        self.path = inputDir.path
        self.name = inputDir.directory
        self.addedDate = Date()
    }

    init?(url: URL) {
        self.path = url.path(percentEncoded: false)

        guard let resourceValues = try? url.resourceValues(forKeys: Self.resourceKeys),
              let name = resourceValues.name,
              let addedDate = resourceValues.addedToDirectoryDate
        else {
            return nil
        }

        self.name = name
        self.addedDate = addedDate
    }

    func nameMatches(query: String?, caseInsensitive: Bool) -> Bool {
        guard let query else { return true }

        var (q, n) = (query, name)

        if caseInsensitive {
            q = q.lowercased()
            n = n.lowercased()
        }

        return n.firstMatch(of: q.fuzzyMatchPattern) != nil
    }

    static let resourceKeys = Set<URLResourceKey>([.nameKey, .addedToDirectoryDateKey])
}

extension File: AlfredListItemConvertible {
    var asAlfredListItem: AlfredListItem { AlfredListItem(file: self) }
}

private extension String {
    func fuzzyMatchPattern() -> some RegexComponent {
        let fuzzyPattern = map { "\($0).*" }.joined()
        return try! Regex(fuzzyPattern)
    }
}

extension AlfredListItem {
    init(file: File) {
        self.init(
            uid: nil,
            title: file.name,
            subtitle: file.path,
            arguments: .single(file.path),
            icon: Icon(path: file.path, type: .fileIcon),
            isValid: true,
            match: nil,
            autocomplete: file.name,
            type: .skipFileCheck,
            modifierActions: nil,
            action: .universalAction(.file(file.path)),
            text: Text(copy: file.path, largeType: file.name),
            quicklookURL: file.path,
            skipKnowledge: true
        )
    }
}
