//
//  ZWBMenuItem.swift
//  ZWB_SegmentedView
//

import UIKit

public struct ZWBMenuItem: Equatable {
    /// Text displayed by a normal menu item. Keep this non-optional so the
    /// existing `ZWBMenuItem(title:)` call sites remain source compatible.
    public var title: String
    public var identifier: String?
    public var badgeImage: UIImage?
    public var badgePlacement: ZWBMenuItemBadgePlacement
    /// Image displayed when the item is not selected. Use this for discover
    /// style image-only tabs such as activity entries.
    public var normalImage: UIImage?
    /// Image displayed when selected. Falls back to `normalImage` when nil.
    public var selectedImage: UIImage?

    public init(
        title: String,
        identifier: String? = nil,
        badgeImage: UIImage? = nil,
        badgePlacement: ZWBMenuItemBadgePlacement = .trailingTop,
        normalImage: UIImage? = nil,
        selectedImage: UIImage? = nil
    ) {
        self.title = title
        self.identifier = identifier
        self.badgeImage = badgeImage
        self.badgePlacement = badgePlacement
        self.normalImage = normalImage
        self.selectedImage = selectedImage
    }

    /// Creates an image-only menu item while keeping `title` as an empty
    /// string for compatibility with older text-only assumptions.
    public init(
        normalImage: UIImage?,
        selectedImage: UIImage? = nil,
        identifier: String? = nil
    ) {
        self.title = ""
        self.identifier = identifier
        self.badgeImage = nil
        self.badgePlacement = .trailingTop
        self.normalImage = normalImage
        self.selectedImage = selectedImage
    }

    public var isImageOnly: Bool {
        title.isEmpty && normalImage != nil
    }
}

public enum ZWBMenuItemBadgePlacement {
    case leadingCenter
    case trailingTop
}
