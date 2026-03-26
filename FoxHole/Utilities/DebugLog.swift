import Foundation

enum DebugLog {
    static let logFileURL: URL = {
        let url = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("FoxHoleDebug.log")
        // Clear log on launch
        try? "".write(to: url, atomically: true, encoding: .utf8)
        return url
    }()

    static func log(_ message: String, file: String = #file, line: Int = #line) {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let fileName = (file as NSString).lastPathComponent
        let entry = "[\(timestamp)] \(fileName):\(line) — \(message)\n"
        print(entry, terminator: "") // also to Xcode console
        if let data = entry.data(using: .utf8),
           let handle = try? FileHandle(forWritingTo: logFileURL) {
            handle.seekToEndOfFile()
            handle.write(data)
            handle.closeFile()
        }
    }
}
