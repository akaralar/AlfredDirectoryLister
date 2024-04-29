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
        help: "Directory to list",
        transform: URL.init(string:)
    )
    var directory: URL?

    @Option(
        name: [.short, .long],
        help: "Maximum items to return"
    )
    var maxItems: Int = 0

    @Flag(
        name: [.customShort("i"), .customLong("include-dir")],
        help: "Flag to denote if the input directory is returned as the first item in the list"
    )
    var shouldIncludeInputDirectory: Bool = false

    mutating func run() throws {
        print(try AlfredListItem.dummy.toJSON())
    }
}
