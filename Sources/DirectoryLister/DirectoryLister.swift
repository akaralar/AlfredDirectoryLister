// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import Foundation
import ArgumentParser
import AlfredJSONEncoder

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
        help: "Maximum items to return. If zero or negative, all items will be returned"
    )
    var maxItems: Int = 0

    @Flag(
        name: [.customShort("i"), .customLong("include-dir")],
        help: "Returns the input directory as the first item in the list"
    )
    var shouldIncludeInputDirectory: Bool = false

    @Flag(
        name: [.customShort("c"), .customLong("case-insensitive")],
        help: "Case-insensitive matching of query"
    )
    var caseInsensitive: Bool = false

    mutating func run() throws {
        guard let inputDir = InputDirectory(directory: directory) else {
            let list = AlfredList(items: [Error(text: "Invalid directory")])
            print(try list.toJSON())
            return
        }

        let sortedFiles = inputDir.files(matching: query, caseInsensitive: caseInsensitive, maxItems: maxItems)
        var alfredList = if sortedFiles.isEmpty {
            AlfredList(items: [Error(text: "No results matching input")])
        } else {
            AlfredList(items: sortedFiles)
        }

        if shouldIncludeInputDirectory {
            alfredList.items.insert(File(inputDir: inputDir).asAlfredListItem, at: 0)
        }

        print(try alfredList.toJSON())
    }
}

