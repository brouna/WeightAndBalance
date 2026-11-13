import Foundation

enum Fixtures {
    static let testsDirectory = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
    static let repositoryRoot = testsDirectory.deletingLastPathComponent().deletingLastPathComponent()

    static func url(_ name: String) -> URL {
        testsDirectory.appendingPathComponent("Fixtures").appendingPathComponent(name)
    }

    static func data(_ name: String) throws -> Data {
        try Data(contentsOf: url(name))
    }

    /// The JSON shipped in the app bundle.
    static let defaultTypesURL = repositoryRoot
        .appendingPathComponent("WeightandBalance/Resources/DefaultTypes.json")

    static func temporaryDirectory() throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("WeightAndBalanceTests-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }
}
