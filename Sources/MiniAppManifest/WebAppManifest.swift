import struct Foundation.Data
import class Foundation.JSONDecoder

/// A WebApp manifest.
///
/// https://www.w3.org/TR/appmanifest/#web-application-manifest
public struct WebAppManifest : Hashable, Codable {
    /// The manifest's `background_color` member describes the expected background color of the MiniApp. It repeats what is already available in the application stylesheet but can be used by the user agent to draw the background color of a MiniApp for which the manifest is known before the files are actually available, whether they are fetched from the network or retrieved from disk.
    ///
    /// The `background_color` member is only meant to improve the user experience while a MiniApp is loading and MUST NOT be used by the user agent as the background color when the MiniApp's stylesheet is available.
    public var background_color: String?

    /// The manifest's dir member specifies the base direction for the localizable members of the manifest. The dir member's value can be set to a text-direction.
    ///
    /// e.g. "ltr"
    public var dir: TextDirection?

    /// The manifest's display member represents the developer's preferred display mode for the MiniApp. Its value is a display mode.
    public var display: DisplayMode?

    /// The manifest's `icons` member are images that serve as iconic representations of the web application in various contexts. For example, they can be used to represent the web application amongst a list of other applications, or to integrate the web application with an OS's task switcher and/or system preferences.
    public var icons: [ImageResource]?

    /// The manifest's `id` member is a string that represents the identity for the application. The identity takes the form of a URL, which is same origin as the start URL.
    ///
    /// The identity is used by user agents to uniquely identify the application universally. When the user agent sees a manifest with an identity that does not correspond to an already-installed application, it SHOULD treat that manifest as a description of a distinct application, even if it is served from the same URL as that of another application. When the user agent sees a manifest where manifest["id"] is equal with exclude fragment true to the identity of an already-installed application, it SHOULD be used as a signal that this manifest is a replacement for the already-installed application's manifest, and not a distinct application, even if it is served from a different URL than the one seen previously.
    public var identity: String

    /// The manifest's `lang` member is a string in the form of a language tag that specifies the primary language for the values of the manifest's localizable members (as knowing the language can also help with directionality).
    ///
    /// A language tag is a string that matches the production of a Language-Tag defined in the [BCP47] specifications (see the IANA Language Subtag Registry for an authoritative list of possible values). That is, a language range is composed of one or more subtags that are delimited by a U+002D HYPHEN-MINUS ("-"). For example, the 'en-AU' language range represents English as spoken in Australia, and 'fr-CA' represents French as spoken in Canada. Language tags that meet the validity criteria of [RFC5646] section 2.2.9 that can be verified without reference to the IANA Language Subtag Registry are considered structurally valid.
    public var lang: String?

    /// The manifest's name member is a string that represents the name of the MiniApp as it is usually displayed to the user (e.g., amongst a list of other applications, or as a label for an icon).
    ///
    /// The name member serves as the accessible name of an installed MiniApp.
    ///
    /// e.g. "Super Racer 3000"
    public var name: String

    /// The manifest's orientation member is a string that serves as the default screen orientation for all top-level browsing contexts of the MiniApp. The possible values are those of the OrientationLockType enum, which in this specification are referred to as the orientation values (i.e., "any", "natural", "landscape", "portrait", "portrait-primary", "portrait-secondary", "landscape-primary", or "landscape-secondary").
    ///
    /// If the user agent supports the value of the orientation member as the default screen orientation, then that serves as the default screen orientation for the life of the MiniApp (unless overridden by some other means at runtime). This means that the user agent MUST return the orientation to the default screen orientation any time the orientation is unlocked [SCREEN-ORIENTATION] or the top-level browsing context is navigated.
    public var orientation: Orientation?

    /// The `scope` member tells the host environment which documents are part of an app, and which are not - and hence, to which set of pages the manifest is "applied" when the user navigates.
    ///
    /// e.g. "/"
    public var scope: String?

    /// The manifest's `short_name` member is a string that represents a short version of the name of the MiniApp. It is intended to be used where there is insufficient space to display the full name of the MiniApp.
    ///
    /// e.g. "Racer3K"
    public var short_name: String?

    /// The manifest's shortcuts member is an list of shortcut items that provide access to key tasks within a MiniApp.
    ///
    /// How shortcuts are presented, and how many of them are shown to the user, is at the discretion of the user agent and/or operating system.
    public var shortcuts: [ShortcutItem]?

    /// The manifest's `start_url` member is a string that represents the start URL , which is URL that the developer would prefer the user agent load when the user launches the MiniApp (e.g., when the user clicks on the icon of the MiniApp from a device's application menu or homescreen).
    ///
    /// The `start_url` member is purely advisory, and a user agent MAY ignore it or provide the end-user the choice not to make use of it. A user agent MAY also allow the end-user to modify the URL when, for instance, a bookmark for the MiniApp is being created or any time thereafter.
    public var start_url: String?

    /// The manifest's `theme_color` member serves as the default theme color for an application context. What constitutes a theme color is defined in [HTML].
    ///
    /// If the user agent honors the value of the `theme_color` member as the default theme color, then that color serves as the theme color for all browsing contexts to which the manifest is applied. However, a document may override the default theme color through the inclusion of a valid [HTML] meta element whose name attribute value is "theme-color".
    public var theme_color: AppColor?

    /// A display mode represents how the MiniApp is being presented within the context of an OS (e.g., in fullscreen, etc.). Display modes correspond to user interface (UI) metaphors and functionality in use on a given platform. The UI conventions of the display modes are purely advisory and implementers are free to interpret them how they best see fit.
    ///
    /// https://www.w3.org/TR/mediaqueries-5/#display-mode
    public enum DisplayMode : String, Hashable, Codable {
        case fullscreen = "fullscreen"
        case standalone = "standalone"
        case minimalUI = "minimal-ui"
        case browser = "browser"
    }

    public enum Orientation : String, Hashable, Codable {
        case any = "any"
        case natural = "natural"
        case landscape = "landscape"
        case portrait = "portrait"
        case portraitPrimary = "portrait-primary"
        case portraitSecondary = "portrait-secondary"
        case landscapePrimary = "landscape-primary"
        case landscapeSecondary = "landscape-secondary"
    }

    /// https://www.w3.org/TR/appmanifest/#dfn-shortcut-item
    public struct ShortcutItem : Hashable, Codable {
        /// The shortcut item's `name` member is a string that represents the name of the shortcut as it is usually displayed to the user in a context menu.
        public var name: String?

        /// The shortcut item's `short_name` member is a string that represents a short version of the name of the shortcut. It is intended to be used where there is insufficient space to display the full name of the shortcut.
        public var short_name: String?

        /// The shortcut item's `description` member is a string that allows the developer to describe the purpose of the shortcut. User agents MAY expose this information to assistive technology.
        public var description: String?

        /// The shortcut item's `url` member is a URL within scope of a processed manifest that opens when the associated shortcut is activated.
        public var url: String?

        /// The shortcut item's `icons` member lists images that serve as iconic representations of the shortcut in various contexts.
        public var icons: [ImageResource]?
    }
}

public extension WebAppManifest {
    static func decode(from data: Data) throws -> Self {
        try decoder.decode(Self.self, from: data)
    }

    private static let decoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
}

extension WebAppManifest : AppManifest {
    public var id: String { identity }
}

