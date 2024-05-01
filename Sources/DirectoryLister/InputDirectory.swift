// Created by Ahmet Karalar for  in 2024
// Using Swift 5.0


import Foundation
import AlfredJSONEncoder

struct InputDirectory {
    let directory: String
    let url: URL
    var path: String

    private var fm: FileManager

    init?(directory: String) {
        fm = FileManager.default
        self.directory = directory
        if directory.starts(with: "~") {
            if let path = directory.expandingTilde() {
                url = URL(fileURLWithPath: path, isDirectory: true)
            } else {
                return nil
            }
        } else if directory.starts(with: "/") {
            url = URL(fileURLWithPath: directory, isDirectory: true)
        } else {
            url = fm.homeDirectoryForCurrentUser.appending(path: directory)
        }

        path = url.path(percentEncoded: false)

        var isDir: ObjCBool = false
        guard fm.fileExists(atPath: path, isDirectory: &isDir) && isDir.boolValue else {
            return nil
        }
    }

    func files(matching query: String?, caseInsensitive: Bool, maxItems: Int = 0) -> [any AlfredListItemConvertible] {
        let directoryEnumerator = fm.enumerator(
            at: url,
            includingPropertiesForKeys: Array(File.resourceKeys),
            options: [.skipsPackageDescendants, .skipsSubdirectoryDescendants]
        )!

        var files: [File] = []
        for case let fileURL as URL in directoryEnumerator {
            guard 
                let file = File(url: fileURL),
                file.nameMatches(query: query, caseInsensitive: caseInsensitive)
            else {
                continue
            }

            files.append(file)
        }

        let sorted = files.sorted { $0.addedDate > $1.addedDate }
        return maxItems <= 0 ? sorted : Array(sorted.prefix(maxItems))
    }
}

private extension String {
    func expandingTilde() -> String? {
        if starts(with: "~/") {
            return replacingOccurrences(
                of: "~/",
                with: FileManager.default.homeDirectoryForCurrentUser.path()
            ).removingPercentEncoding!
        } else if starts(with: "~") {
            return nil
        } else {
            return self
        }
    }
}
