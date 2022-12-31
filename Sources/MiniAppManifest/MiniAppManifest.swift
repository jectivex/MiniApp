import struct Foundation.Data
import class Foundation.JSONDecoder

/// A application manifest is a [JSON] document that contains startup parameters and application defaults for when a MiniApp is launched.
///
/// https://w3c.github.io/miniapp-manifest/
public struct MiniAppManifest : Hashable, Codable {

    // MARK: Web Application Manifest members – https://w3c.github.io/miniapp-manifest/#webappmanifest-members

    /// The MiniApp manifest's dir member, while specifying the base direction of the localizable members of the manifest, also specifies the default base text direction of the whole MiniApp.
    public var dir: TextDirection?

    /// The MiniApp manifest's icons member describes images that serve as iconic representations of MiniApps. This member is a list of image resource ordered maps.
    public var icons: [ImageResource]?

    /// The MiniApp manifest's lang member, while specifying the primary language of the localizable members, also specifies the primary language of the whole MiniApp. This member is a string in the form of a language tag, a string that matches the production of a Language-Tag [BCP47], as defined in [APPMANIFEST].
    public var lang: String?

    /// The MiniApp manifest's name member is the descriptive name of the application. This is the name directly displayed to the user. It is used as the display name of MiniApp along with the desktop icon and in the context of MiniApp management.
    public var name: String

    /// The MiniApp manifest's `short_name` member provides a concise and easy-to-read name for a MiniApp. It can be used when there is insufficient space to display the full MiniApp name provided in name.
    public var short_name: String?

    // MARK: Application Information members – https://w3c.github.io/miniapp-manifest/#webappmanifest-app-info-members

    /// The MiniApp manifest's `description` member provides a textual description for the MiniApp representing the purpose of the web application in natural language, as defined in [MANIFEST-APP-INFO]
    public var description: String?


    // MARK: Supplementary members – https://w3c.github.io/miniapp-manifest/#supplementary-manifest-members

    /// The MiniApp manifest's `app_id` member is a string that identifies the MiniApp univocally. This member is mainly used for package management, and it supports the update and release process of MiniApp versioning.
    public var app_id: String

    /// The optional MiniApp manifest's `color_scheme` member is a string that indicates the preferred color scheme of a MiniApp (i.e., "auto", "light, or "dark"), overriding other configuration members of the window resource object, including `background_color`, `background_text_style`, `navigation_bar_text_style`, and `navigation_bar_title_text`.
    public var color_scheme: String?

    /// The optional MiniApp manifest's `device_type` member is a list of strings that indicates the type of devices on which the MiniApp is intended to run. The values of this member inform user agents if the MiniApp has been designed to properly run on specific platforms like smartphones, smart TVs, car head units, wearables, and other devices.
    public var device_type: [SupportedDevice]?

    /// The MiniApp manifest's pages member is a list of relative-url string used for specifying the collection of pages that are part of a MiniApp. Each item in the list represents a page identified by its page route.
    ///
    /// A MiniApp page route is the relative path and filename of a MiniApp page. When configuring the page routes, developers MAY omit the extension of the file that defines the main component of the page (e.g., pages/mypage or pages/mypage.html).
    public var pages: [Page]?

    /// The MiniApp manifest's `platform_version` member contains a MiniApp platform version resource ordered map for describing the minimum requirements and intended platform version to run a MiniApp, including `min_code`, `target_code`, and `release_type`.
    public var platform_version: PlatformVersion?

    /// The optional MiniApp manifest's `req_permissions` member is a list of MiniApp permission resources ordered map.
    ///
    /// Each MiniApp permission resource declares a request for using a concrete system feature (e.g., access to device's location, user contacts, sensors, and camera) required for the proper execution of a MiniApp.
    public var req_permissions: [Permission]?

    /// The MiniApp manifest's version member contains a MiniApp version resource ordered map to represent the code and name.
    public var version: Version?

    /// The optional MiniApp manifest's widgets member is a list of MiniApp widget resources that are a part of a MiniApp.
    public var widgets: [Widget]?

    /// The optional MiniApp manifest's window member contains a MiniApp window resource ordered map to describe the look and feel of a MiniApp frame, including the styles of the status bar, navigation bar, title, background colors, among other visual configuration elements.
    public var window: WindowStyle?


    public init(dir: TextDirection? = nil, icons: [ImageResource]? = nil, lang: String? = nil, name: String, short_name: String? = nil, description: String? = nil, app_id: String, color_scheme: String? = nil, device_type: [SupportedDevice]? = nil, pages: [Page]? = nil, platform_version: PlatformVersion? = nil, req_permissions: [Permission]? = nil, version: Version? = nil, widgets: [Widget]? = nil, window: WindowStyle? = nil) {
        self.dir = dir
        self.icons = icons
        self.lang = lang
        self.name = name
        self.short_name = short_name
        self.description = description
        self.app_id = app_id
        self.color_scheme = color_scheme
        self.device_type = device_type
        self.pages = pages
        self.platform_version = platform_version
        self.req_permissions = req_permissions
        self.version = version
        self.widgets = widgets
        self.window = window
    }

    /// The optional MiniApp manifest's `device_type` member is a list of strings that indicates the type of devices on which the MiniApp is intended to run. The values of this member inform user agents if the MiniApp has been designed to properly run on specific platforms like smartphones, smart TVs, car head units, wearables, and other devices.
    public struct SupportedDevice : RawRepresentable, Hashable, Codable {
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

    /// The MiniApp manifest's `pages` member is a list of relative-url string used for specifying the collection of pages that are part of a MiniApp. Each item in the list represents a page identified by its page route.
    ///
    /// A MiniApp page route is the relative path and filename of a MiniApp page. When configuring the page routes, developers MAY omit the extension of the file that defines the main component of the page (e.g., pages/mypage or pages/mypage.html).
    public struct Page : RawRepresentable, Hashable, Codable {
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

    /// A MiniApp version resource is an ordered map that describes the version code and version name of a MiniApp.
    public struct Version : Hashable, Codable {
        /// The MiniApp version resource's `code` member is a non-negative integer number that represents the version of a MiniApp. It is mainly used for enhancing the maintainability and security of MiniApp (e.g., compatibility among incremental versions). The code member aims at supporting the development and deployment process, and it is not usually displayed to the end-user.
        public var code: UInt

        /// The MiniApp version resource's `name` member is a string mainly used for describing information on the version of a MiniApp, playing an essential role in version control, MiniApp application, and platform compatibility. It is usually considered as the version that is shown publicly and displayed to the user.
        public var name: String

        public init(code: UInt, name: String) {
            self.code = code
            self.name = name
        }
    }

    /// A MiniApp platform version resource is an ordered map that indicates the minimum and target platform versions to be used by the MiniApp.
    ///
    /// https://w3c.github.io/miniapp-manifest/#sec-platform-version-resources
    public struct PlatformVersion : Hashable, Codable {
        /// The MiniApp platform version resource's min_code member is a non-negative integer number that indicates the minimum supported version of the MiniApp user agent's platform to ensure the regular operation of a MiniApp.
        public var min_code: UInt

        /// The MiniApp platform version resource's `release_type` member is a string that indicates the release type of the MiniApp user agent's target platform version that is required for running an application.
        public var release_type: String

        /// The MiniApp platform version resource's `target_code` member is a non-negative integer number that indicates the target supported version of the MiniApp user agent's platform to ensure the regular operation of a MiniApp.
        public var target_code: UInt

        public init(min_code: UInt, release_type: String, target_code: UInt) {
            self.min_code = min_code
            self.release_type = release_type
            self.target_code = target_code
        }
    }

    /// A MiniApp widget resource is an ordered map that defines and configures a widget that is part of a MiniApp.
    public struct Widget : Hashable, Codable {
        /// The MiniApp widget resource's `name` member is a string that indicates the title of a widget.
        public var name: String

        /// The MiniApp widget resource's `path` member is a relative-url string that defines the corresponding page route of a widget, represented as in the pages list.
        public var path: String

        /// The optional MiniApp widget resource's `min_code` member is a number that indicates the minimum platform version supported for a MiniApp widget.
        public var min_code: String?

        public init(name: String, path: String, min_code: String? = nil) {
            self.name = name
            self.path = path
            self.min_code = min_code
        }
    }

    /// A MiniApp permission resource is an ordered map that describes a request for using a concrete system feature (e.g., access to device's location, user contacts, sensors, and camera) required for the proper execution of a MiniApp.
    public struct Permission : Hashable, Codable {
        /// The MiniApp permission resource's name member is a string that indicates the name of the feature requested.
        public let name: String

        /// The optional MiniApp permission resource's reason member is a string that indicates the reason given to request the feature specified in the [MiniApp permission resource/name=] attribute.
        public let reason: String?

        public init(name: String, reason: String?) {
            self.name = name
            self.reason = reason
        }
    }

    /// A MiniApp window resource is an ordered map that defines and configures the window that contains a MiniApp.
    ///
    /// The optional MiniApp manifest's window member contains a MiniApp window resource ordered map to describe the look and feel of a MiniApp frame, including the styles of the status bar, navigation bar, title, background colors, among other visual configuration elements.
    ///
    /// https://w3c.github.io/miniapp-manifest/#sec-window-resource-members
    public struct WindowStyle : Hashable, Codable {
        /// The `auto_design_width` member is a boolean that indicates whether the `design_width` of the page is auto-calculated by the user agent. When `auto_design_width` is true, the value of `design_width` is ignored. In this case, the system's baseline width is automatically determined according to the pixel density of the screen.
        public var auto_design_width: Bool? // Enables/disables auto-calculation of page's design_width

        /// The `background_color` member is a string that specifies the background color of the window that contains a MiniApp.
        public var background_color: AppColor? // Window background color

        /// The `background_text_style` member is a string that specifies the background text style, indicating a light or dark color theme (i.e., "light" or "dark").
        public var background_text_style: String? // Background text style

        /// The `design_width` member is a number that indicates the baseline width of the page design in pixel unit. It is used for visually adjusting the page components.
        public var design_width: Double? // The baseline page design width

        /// The `enable_pull_down_refresh` member is a boolean that specifies if the pull-to-refresh event is enabled during the interaction with the MiniApp.
        public var enable_pull_down_refresh: Bool? // Enable pull-to-refresh event

        /// The `fullscreen` member is a boolean that indicates if the MiniApp is shown in full-screen display mode.
        public var fullscreen: Bool? // Full screen display

        /// The `navigation_bar_background_color` member is a string that specifies the color of the background of the navigation bar of a MiniApp.
        public var navigation_bar_background_color: AppColor? // Navigation bar background color

        /// The `navigation_bar_text_style` member is a string that indicates the text color of the navigation bar title (i.e., "white" or "black").
        public var navigation_bar_text_style: String? // Text style of the navigation bar

        /// The `navigation_bar_title_text` member is a string that specifies the title of the navigation bar of a MiniApp.
        public var navigation_bar_title_text: String? // Navigation bar title

        /// The `navigation_style` member is a string that specifies the style of the navigation bar (i.e., "default" or "custom").
        public var navigation_style: NavigationStyle? // Navigation bar style

        /// The `on_reach_bottom_distance` member is a number that defines the vertical offset from the bottom of the window required to trigger a page pull-up event. Values for this member are non-negative integers expressed in pixel unit.
        public var on_reach_bottom_distance: Double? // Distance for pull-up bottom event triggering

        /// The `orientation` member is a string that specifies the configuration of the screen orientation for the MiniApp.
        public var orientation: Orientation? // Screen orientation settings

        /// https://w3c.github.io/miniapp-manifest/#orientation-member
        public enum Orientation : String, Hashable, Codable {
            case portrait
            case landscape
        }

        /// https://w3c.github.io/miniapp-manifest/#navigation_style-member
        public enum NavigationStyle : String, Hashable, Codable {
            /// For applying the style by default.
            case `default`

            /// For applying a customized navigation bar.
            case custom
        }

        public init(auto_design_width: Bool? = nil, background_color: AppColor? = nil, background_text_style: String? = nil, design_width: Double? = nil, enable_pull_down_refresh: Bool? = nil, fullscreen: Bool? = nil, navigation_bar_background_color: AppColor? = nil, navigation_bar_text_style: String? = nil, navigation_bar_title_text: String? = nil, navigation_style: NavigationStyle? = nil, on_reach_bottom_distance: Double? = nil, orientation: Orientation? = nil) {
            self.auto_design_width = auto_design_width
            self.background_color = background_color
            self.background_text_style = background_text_style
            self.design_width = design_width
            self.enable_pull_down_refresh = enable_pull_down_refresh
            self.fullscreen = fullscreen
            self.navigation_bar_background_color = navigation_bar_background_color
            self.navigation_bar_text_style = navigation_bar_text_style
            self.navigation_bar_title_text = navigation_bar_title_text
            self.navigation_style = navigation_style
            self.on_reach_bottom_distance = on_reach_bottom_distance
            self.orientation = orientation
        }
    }
}

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

extension MiniAppManifest : AppManifest {
    public var id: String { app_id }
}

