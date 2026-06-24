# ZWB_SegmentedView

[简体中文](README.md)

`ZWB_SegmentedView` is a maintained fork-style package based on `JXSegmentedView` `1.4.1`.

It keeps the original `JXSegmentedView` API and adds a small ZWB helper layer for scenes where the visible tab UI needs to be fully custom while `JXSegmentedListContainerView` still drives paging and lazy loading.

## Features

- Fully compatible with the original `JXSegmentedView` public API.
- Adds preset configuration wrappers for common width, spacing, alignment and indicator settings.
- Adds a custom menu driver for scenes where `JXSegmentedView` should keep page/list behavior while a custom `UIView` renders the visible menu.
- Supports mixed text/image custom menu items, selected background images, selected text scaling and image scaling.
- Supports RTL layouts for both the original segmented view and the ZWB custom menu.
- Supports CocoaPods and Swift Package Manager.

## CocoaPods

```ruby
pod 'ZWB_SegmentedView', :git => 'https://github.com/muskspace0806-prog/ZWB_SegmentedView.git', :tag => '1.0.0'
```

## Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/muskspace0806-prog/ZWB_SegmentedView.git", from: "1.0.0")
]
```

## Custom Menu Driver

```swift
let menuView = ZWBSegmentedMenuView()
let segmentedView = JXSegmentedView()
let hiddenDataSource = ZWBHiddenSegmentedDataSource(count: items.count)
let listContainerView = JXSegmentedListContainerView(dataSource: self)

segmentedView.zwb_prepareAsInvisiblePageDriver()
segmentedView.dataSource = hiddenDataSource
segmentedView.listContainer = listContainerView

menuView.reload(items: items)

let coordinator = ZWBSegmentedMenuCoordinator(
    segmentedView: segmentedView,
    menuView: menuView
)
coordinator.onSelectedIndexChanged = { index in
    // update business state once here
}
```

For most scenes, prefer the one-call helper:

```swift
segmentedView.zwb_bindCustomMenu(
    menuView,
    items: items,
    listContainer: listContainerView
) { index in
    // update business state once here
}
```

## Preset Configuration

Existing JXSegmentedView properties still work. The ZWB configuration layer only groups common settings:

```swift
let dataSource = JXSegmentedTitleDataSource()
dataSource.titles = ["General", "Lucky", "VIP", "Package"]

segmentedView.zwb_apply(
    .giftMenu(
        normalColor: UIColor(white: 1, alpha: 0.6),
        selectedColor: .white,
        indicatorColor: .systemPink
    ),
    dataSource: dataSource
)
```

Equivalent manual settings would normally involve `itemWidth`, `itemWidthIncrement`, `itemSpacing`, `isItemSpacingAverageEnabled`, `contentEdgeInsetLeft`, `contentEdgeInsetRight`, and `JXSegmentedIndicatorLineView` properties.

## Custom Menu Without List Container

```swift
segmentedView.zwb_bindCustomMenu(menuView, items: items) { index in
    // update selected content manually
}
```

## Mixed Image And Text Menu

`ZWBSegmentedMenuView` can also cover the `GMDiscoverContainerMenuView` style:
text tabs, image-only tabs, selected background image, larger selected text,
and natural image scaling.

```swift
let menuView = ZWBSegmentedMenuView()
menuView.appearance = .discover(selectedBackgroundImage: UIImage(named: "menu_bg"))

let items: [ZWBMenuItem] = [
    ZWBMenuItem(title: "Discover"),
    ZWBMenuItem(
        normalImage: UIImage(named: "live_activity_fr_select"),
        selectedImage: UIImage(named: "live_activity_fr_select")
    ),
    ZWBMenuItem(title: "News")
]

segmentedView.zwb_bindCustomMenu(menuView, items: items)
```

## RTL

`ZWBSegmentedMenuView` follows the active layout direction automatically. In app code, update the app/window semantic direction as usual:

```swift
UIView.appearance().semanticContentAttribute = .forceRightToLeft
```

The custom menu mirrors its collection view and cells internally, so item order, badge placement and selected states stay consistent with `JXSegmentedView`.

For custom values, use `ZWBSegmentedMenuAppearance` directly:

```swift
menuView.appearance = ZWBSegmentedMenuAppearance(
    normalTextColor: UIColor(white: 1, alpha: 0.55),
    selectedTextColor: .systemPink,
    textFont: .systemFont(ofSize: 15),
    selectedTextFont: .boldSystemFont(ofSize: 17),
    indicatorColor: .systemPink,
    indicatorSize: CGSize(width: 28, height: 2),
    itemHorizontalPadding: 16,
    minimumItemWidth: 64,
    itemSpacing: 8
)
```
