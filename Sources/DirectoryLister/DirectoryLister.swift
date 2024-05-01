// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import Foundation
import ArgumentParser
import AlfredJSONEncoder
import RegexBuilder

@main
struct ListDirectoryMain: ParsableCommand {

    @Option(
        name: [.short, .customLong("dir")],
        help: "Directory to list"
    )
    var directory: String = "~/Downloads"

    @Option(
        name: [.short, .long],
        help: "Query for fuzzy matching of filenames"
    )
    var query: String?

    @Option(
        name: [.short, .customLong("max")],
        help: "Maximum items to return. If zero, all items will be returned"
    )
    var maxItems: Int = 0

    @Flag(
        name: [.customShort("i"), .customLong("include-dir")],
        help: "Returns the input directory as the first item in the list"
    )
    var shouldIncludeInputDirectory: Bool = false

    @Flag(
        name: [.customShort("c"), .customLong("ignore-case")],
        help: "Case-insensitive matching of query"
    )
    var shouldIgnoreCase: Bool = false

    mutating func run() throws {
        let fm = FileManager.default
        
        let url = if directory.starts(with: "~") {
            URL(fileURLWithPath: directory.expandingTilde(), isDirectory: true)
        } else if directory.starts(with: "/") {
            URL(fileURLWithPath: directory, isDirectory: true)
        } else {
            FileManager.default.homeDirectoryForCurrentUser.appending(path: directory)
        }
        var isDir: ObjCBool = false
        if fm.fileExists(atPath: url.path().removingPercentEncoding!, isDirectory: &isDir), isDir.boolValue {
            var sortedFiles = files(in: url, matching: query, maxItems: maxItems)
            let hasNoResults = sortedFiles.isEmpty
            if shouldIncludeInputDirectory {
                sortedFiles.insert(File(url: url, name: directory, addedDate: Date()), at: 0)
            }
            var alfredList = AlfredList(items: sortedFiles.map(AlfredListItem.init(file:)))
            if hasNoResults {
                alfredList.items.append(AlfredListItem(error: "No results matching input"))
            }
            print(try alfredList.toJSON())
        } else {
            let alfredList = AlfredList(items: [AlfredListItem(error: "Directory not found at given path.")])
            print(try alfredList.toJSON())
        }
    }

    func files(in url: URL, matching query: String?, maxItems: Int = 0) -> [File] {
        let resourceKeys = Set<URLResourceKey>([.nameKey, .addedToDirectoryDateKey])
        let fm = FileManager.default
        let directoryEnumerator = fm.enumerator(
            at: url,
            includingPropertiesForKeys: Array(resourceKeys),
            options: [.skipsPackageDescendants, .skipsSubdirectoryDescendants]
        )!

        var files: [File] = []
        for case let fileURL as URL in directoryEnumerator {
            guard let resourceValues = try? fileURL.resourceValues(forKeys: resourceKeys),
                  let name = resourceValues.name,
                  let addedDate = resourceValues.addedToDirectoryDate
            else {
                continue
            }

            let file = File(url: fileURL, name: name, addedDate: addedDate)
            guard let query = query else {
                files.append(file)
                continue
            }

            let (q, n) = if shouldIgnoreCase {
                (query.lowercased(), name.lowercased())
            } else {
                (query, name)
            }

            guard n.firstMatch(of: regexPattern(for: q)) != nil else { continue }
            files.append(file)
        }

        let sorted = files.sorted { $0.addedDate > $1.addedDate }
        return maxItems == 0 ? sorted : Array(sorted.prefix(maxItems))
    }

    private func regexPattern(for query: String) -> some RegexComponent {
        let fuzzyPattern = query.map { "\($0).*" }.joined()
        return try! Regex(fuzzyPattern)
    }
}

struct File {
    var path: String
    var name: String
    var addedDate: Date

    init(url: URL, name: String, addedDate: Date) {
        self.path = url.path(percentEncoded: false)
        self.name = name
        self.addedDate = addedDate
    }
}

extension String {
    func expandingTilde() -> String {
        if starts(with: "~/") {
            return replacingOccurrences(
                of: "~/",
                with: FileManager.default.homeDirectoryForCurrentUser.path()
            ).removingPercentEncoding!

        } else if starts(with: "~") {
            return replacingOccurrences(
                of: "~",
                with: FileManager.default.homeDirectoryForCurrentUser.path()
            ).removingPercentEncoding!
        } else {
            return self
        }
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
            type: .skipCheck,
            modifierActions: nil,
            action: .universalAction(.file(file.path)),
            text: Text(copy: file.path, largeType: file.name),
            quicklookURL: file.path,
            skipKnowledge: true
        )
    }

    init(error text: String) {
        self.init(
            uid: nil,
            title: text,
            subtitle: nil,
            arguments: .single(""),
            icon: Icon(path: "./error.png"),
            isValid: false,
            match: nil,
            autocomplete: nil,
            type: .default,
            modifierActions: nil,
            action: nil,
            text: nil,
            quicklookURL: nil,
            skipKnowledge: true
        )
    }
}
