
/// A manifest for an app, such as ``MiniAppManifest`` ([https://w3c.github.io/miniapp-manifest/](https://w3c.github.io/miniapp-manifest/)) or ``WebAppManifest`` ([https://www.w3.org/TR/appmanifest/](https://www.w3.org/TR/appmanifest/)).
public protocol AppManifest {
    var id: String  { get }

    /// Primary language (BCP47) for the values of the manifest's localizable members.
    var lang: String? { get }

    /// Represents the name of the app as it is usually displayed to the user (e.g., amongst a list of other applications, or as a label for an icon).
    var name: String  { get }

    /// Represents a short version of the name of the app. It is intended to be used where there is insufficient space to display the full name of the app.
    var short_name: String? { get }

    /// Base direction for the localizable members of the manifest.
    var dir: TextDirection? { get }

    /// Images that serve as iconic representations of the app in various contexts. For example, they can be used to represent the app amongst a list of other applications, or to integrate the app with an OS's task switcher and/or system preferences.
    var icons: [ImageResource]? { get }
}

/// https://www.w3.org/TR/appmanifest/#dfn-text-directions
public enum TextDirection : String, Hashable, Codable {
    case ltr, rtl, auto
}

/// A Hex, CSS or named color.
///
/// https://www.w3.org/TR/appmanifest/#dfn-background_color
public struct AppColor : RawRepresentable, Hashable, Codable {
    public var rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(from decoder: Decoder) throws {
        try self.init(rawValue: RawValue(from: decoder))
    }

    public func encode(to encoder: Encoder) throws {
        try rawValue.encode(to: encoder)
    }
}

/// https://www.w3.org/TR/image-resource/#dfn-label
public struct ImageResource : Hashable, Codable {
    /// A URL from where to obtain the image data.
    public var src: String?

    /// An optional string representing the sizes of the image, expressed using the same syntax as link's sizes attribute.
    ///
    /// https://html.spec.whatwg.org/multipage/semantics.html#attr-link-sizes
    public var sizes: String?

    /// An optional image MIME type.
    public var type: String?

    /// A string representing the accessible name of the image.
    public var label: String?
}
