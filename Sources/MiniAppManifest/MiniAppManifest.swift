import Foundation

public extension MiniAppManifest {
    static func decode(from data: Data) throws -> Self {
        try decoder.decode(Self.self, from: data)
    }

    private static let decoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
}

/// A application manifest is a [JSON] document that contains startup parameters and application defaults for when a MiniApp is launched.
///
/// https://w3c.github.io/miniapp-manifest/
public struct MiniAppManifest : Hashable, Codable {
    public var app_id: String // MiniApp identifier
    public var color_scheme: String? // MiniApp color scheme
    public var description: String? // MiniApp description
    public var device_type: [SupportedDevice]? // Supporting devices
    public var dir: WebAppManifest.Dir? // Direction of texts
    public var icons: [Icon] // MiniApp icons
    public var lang: String? // MiniApp primary language
    public var name: String // MiniApp name
    public var pages: [Page] // Page routing information
    public var platform_version: PlatformVersion // Platform version supported
    public var req_permissions: [Permission]? // Required permissions
    public var short_name: String? // MiniApp short name
    public var version: Version // MiniApp version
    public var widgets: [Widget]? // MiniApp widgets
    public var window: WindowStyle? // Window style

    public struct SupportedDevice : Hashable, Codable {
    }

    public struct Icon : Hashable, Codable {
    }

    public struct Page : Hashable, Codable {
    }

    public struct Version : Hashable, Codable {
    }

    public struct PlatformVersion : Hashable, Codable {
    }

    public struct Widget : Hashable, Codable {
    }

    public struct Permission : Hashable, Codable {
    }

    public struct WindowStyle : Hashable, Codable {
    }

}


