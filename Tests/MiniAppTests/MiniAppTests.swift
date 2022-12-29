import XCTest
import MiniApp

final class MiniAppTests: XCTestCase {
    /// Tests the various metadata from the submodule linked to https://github.com/w3c/miniapp-tests
    func testExamples() throws {
        let base = try XCTUnwrap(Bundle.module.url(forResource: "miniapp-tests", withExtension: nil))
        let testURL = base.appendingPathComponent("tests", isDirectory: true)
        let baseContents = try testURL.directoryContents(deep: false)

        let mafiles = baseContents.filter({ $0.pathExtension == "ma" })
        XCTAssertGreaterThan(mafiles.count, 5)
        for maFile in mafiles {
            try checkMAFile(maFile)
        }

        let subfolders = baseContents.filter(\.isDirectory)
        XCTAssertGreaterThan(subfolders.count, 5)

        for folder in subfolders {
            try checkMAFolder(folder)
        }
    }

    func checkMAFile(_ url: URL) throws {
        print("checking MAFile:", url.lastPathComponent)
        // TODO: check zip format
    }

    func checkMAFolder(_ url: URL) throws {
        print("checking MAFolder:", url.lastPathComponent)
        if url.lastPathComponent == "xx-miniapp-template" {
            return // the data in the template itself is incomplete and/or invalid
        }

        let ld = try LD.decode(from: Data(contentsOf: url.file(named: "test.jsonld")))
        XCTAssertEqual("earl:TestCase", ld.type)

        print("  coverage:", ld.coverage)
        print("  title:", ld.title)
        print("  description:", ld.description)
        print("  type:", ld.type)

        let src = try url.directory(named: "src")
        let common = try src.directory(named: "common")
        let commonFiles = try common.directoryContents(deep: false)
        print("commonFiles:", commonFiles.map(\.lastPathComponent))

        let pages = try src.directory(named: "pages")
        let pagesFiles = try pages.directoryContents(deep: false)
        print("pagesFiles:", pagesFiles.map(\.lastPathComponent))

        let manifest = try MiniAppManifest.decode(from: Data(contentsOf: src.file(named: "manifest.json")))
        XCTAssertNotEqual("", manifest.name)
        XCTAssertEqual("org.example.miniapp", manifest.id)
        XCTAssertEqual(1, manifest.pages.count)
        XCTAssertEqual(1, manifest.icons?.count)
        //XCTAssertNotNil(manifest.short_name)

        // app.js contains the basic service logic of the MiniApp and includes the essential configuration and control of the MiniApp lifecycle, including the management of events for launching, showing, and hiding the MiniApp.
        let appJS = try src.file(named: "app.js")
        let _ = try Data(contentsOf: appJS)
}
}

extension URL {
    /// True if this is a file URL and it is a directory.
    var isDirectory: Bool {
        get {
            isFileURL && (try? resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true
        }
    }

    /// Returns the file child of the given folder URL.
    func directory(named name: String) throws -> URL {
        let url = self.appendingPathComponent(name, isDirectory: true)
        if !FileManager.default.fileExists(atPath: url.path) {
            throw CocoaError(.fileNoSuchFile)
        }
        if !url.isDirectory {
            throw CocoaError(.fileReadUnknown)
        }
        return url
    }

    /// Returns the file child of the given folder URL.
    func file(named name: String) throws -> URL {
        let url = self.appendingPathComponent(name, isDirectory: false)
        if url.isDirectory {
            throw CocoaError(.fileReadNoSuchFile)
        }
        if !FileManager.default.fileExists(atPath: url.path) {
            throw CocoaError(.fileNoSuchFile)
        }
        if !FileManager.default.isReadableFile(atPath: url.path) {
            throw CocoaError(.fileReadNoPermission)
        }
        return url
    }

    /// The contents of this file URL.
    func directoryContents(deep: Bool) throws -> [URL] {
        guard isFileURL else { throw URLError(.fileDoesNotExist) }

        var enumerationError: Error?
        guard let pathEnumerator = FileManager.default.enumerator(at: self, includingPropertiesForKeys: [.isDirectoryKey], options: .skipsSubdirectoryDescendants, errorHandler: { url, error in
            enumerationError = error
            return false
        }) else {
            return []
        }
        if let enumerationError = enumerationError {
            throw enumerationError
        }

        return pathEnumerator.compactMap({ $0 as? URL })
    }
}

extension LD {
    static func decode(from data: Data) throws -> Self {
        try decoder.decode(Self.self, from: data)
    }

    private static let decoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
}

struct LD : Decodable {
    let context: Context
    let rights: URL
    let rightsHolder: URL
    let type: String
    let coverage: Coverage
    let conformsTo: String?
    let creator: [String]
    let date: String // YYYY-MM-DD
    let title: String
    let identifier: String
    let description: String
    let terms: [URL]
    let modified: Date

    enum CodingKeys : String, CodingKey {
        case context = "@context"
        case rights = "dcterms:rights"
        case rightsHolder = "dcterms:rightsHolder"
        case type = "@type"
        case coverage = "dc:coverage"
        case conformsTo = "dcterms:conformsTo"
        case creator = "dc:creator"
        case date = "dc:date"
        case title = "dc:title"
        case identifier = "dc:identifier"
        case description = "dc:description"
        case terms = "dcterms:isReferencedBy"
        case modified = "dcterms:modified"
    }

    enum Coverage : String, Decodable {
        case packaging = "Packaging"
        case lifecycle = "Lifecycle"
        case manifest = "Manifest"
    }

    struct Context : Decodable {
        let dc: URL
        let dcterms: URL
        let foaf: URL
        let earl: URL
        let xsd: URL
        let page: Page

        enum CodingKeys : String, CodingKey {
            case dc = "dc"
            case dcterms = "dcterms"
            case foaf = "foaf"
            case earl = "earl"
            case xsd = "xsd"
            case page = "foaf:page"
        }

        struct Page : Decodable {
            let type: String

            enum CodingKeys : String, CodingKey {
                case type = "@type"
            }
        }
    }
}
