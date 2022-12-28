import XCTest
@testable import MiniApp

final class MiniAppTests: XCTestCase {
    /// Tests the various metadata from the submodule linked to https://github.com/w3c/miniapp-tests
    func testExamples() throws {
        let base = try XCTUnwrap(Bundle.module.url(forResource: "miniapp-tests", withExtension: nil))
        let testURL = base.appendingPathComponent("tests", isDirectory: true)
        guard let pathEnumerator = FileManager.default.enumerator(at: testURL, includingPropertiesForKeys: [.isDirectoryKey], options: .skipsSubdirectoryDescendants, errorHandler: { url, error in
            XCTFail("error \(error) with url \(url.path)")
            return false
        }) else {
            return XCTFail("no enumerator")
        }
        let urls = pathEnumerator.compactMap({ $0 as? URL })

        let mafiles = urls.filter({ $0.pathExtension == "ma" })
        XCTAssertGreaterThan(mafiles.count, 5)
        for maFile in mafiles {
            try checkMAFile(maFile)
        }

        let subfolders = try urls.filter({ try $0.resourceValues(forKeys: [.isDirectoryKey]).isDirectory == true })
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
        // TODO: check folder
    }
}
