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

        if let url = fm.fileURL(for: directory) {
            self.url = url
        } else {
            return nil
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

private extension FileManager {
    func fileURL(for directory: String) -> URL? {
        if directory.starts(with: "~") {
            if let path = expandingTilde(in: directory) {
                return URL(fileURLWithPath: path, isDirectory: true)
            } else {
                return nil
            }
        } else if directory.starts(with: "/") {
            return URL(fileURLWithPath: directory, isDirectory: true)
        } else {
            return homeDirectoryForCurrentUser.appending(path: directory)
        }
    }

    private func expandingTilde(in path: String) -> String? {
        if path.starts(with: "~/") {
            return path.replacingOccurrences(
                of: "~/",
                with: homeDirectoryForCurrentUser.path(percentEncoded: false)
            )
        } else if path.starts(with: "~") && path.count > 0 {
            return nil
        } else if path == "~" {
            return path.replacingOccurrences(
                of: "~",
                with: homeDirectoryForCurrentUser.path(percentEncoded: false)
            )
        } else {
            return path
        }
    }
}
