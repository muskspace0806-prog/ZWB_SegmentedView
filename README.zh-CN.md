# ZWB_SegmentedView

[English](README.md)

`ZWB_SegmentedView` 是基于 `JXSegmentedView` `1.4.1` 维护的扩展版本。

它保留原始 `JXSegmentedView` 的公开 API，同时新增 ZWB 封装层，用来解决常见配置冗余、自定义菜单、图文混排、RTL 等场景。

## 特性

- 兼容原有 `JXSegmentedView` 的方法和属性。
- 封装常见宽度、间距、对齐方式、指示器配置。
- 支持把 `JXSegmentedView` 作为隐藏的页面驱动器，同时用自定义 `UIView` 展示菜单。
- 支持文本、图片、图文混排菜单。
- 支持选中背景图、选中文字放大、选中图片缩放。
- 自定义菜单内部自动适配 RTL，阿语场景下 item 顺序、badge、选中态都会跟随翻转。
- 支持 CocoaPods 和 Swift Package Manager。

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

## 常用配置封装

原始 JX 属性仍然可用。ZWB 配置层只是把常见组合收口，减少重复设置：

```swift
let dataSource = JXSegmentedTitleDataSource()
dataSource.titles = ["通用", "幸运", "VIP", "背包"]

segmentedView.zwb_apply(
    .giftMenu(
        normalColor: UIColor(white: 1, alpha: 0.6),
        selectedColor: .white,
        indicatorColor: .systemPink
    ),
    dataSource: dataSource
)
```

如果有特殊需求，也可以继续覆盖原来的 JX 属性：

```swift
dataSource.itemSpacing = 12
segmentedView.indicators = [indicator]
```

## 自定义菜单驱动

当页面仍然需要 `JXSegmentedListContainerView` 的联动、懒加载和滑动能力，但可见菜单要完全自定义时，可以这样使用：

```swift
let segmentedView = JXSegmentedView()
let menuView = ZWBSegmentedMenuView()
let listContainerView = JXSegmentedListContainerView(dataSource: self)

segmentedView.zwb_bindCustomMenu(
    menuView,
    items: items,
    listContainer: listContainerView
) { index in
    // 在这里处理业务选中状态
}
```

如果只是需要一个可见菜单，不需要 listContainer，也可以省略：

```swift
segmentedView.zwb_bindCustomMenu(menuView, items: items) { index in
    // 手动更新当前内容
}
```

## 图文混排菜单

可以覆盖类似 `GMDiscoverContainerMenuView` 的场景：文本 tab、图片 tab、选中背景图、选中文字放大、图片自然缩放。

```swift
let menuView = ZWBSegmentedMenuView()
menuView.appearance = .discover(selectedBackgroundImage: UIImage(named: "menu_bg"))

let items: [ZWBMenuItem] = [
    ZWBMenuItem(title: "发现"),
    ZWBMenuItem(
        normalImage: UIImage(named: "live_activity_fr_select"),
        selectedImage: UIImage(named: "live_activity_fr_select")
    ),
    ZWBMenuItem(title: "动态")
]

segmentedView.zwb_bindCustomMenu(
    menuView,
    items: items,
    listContainer: listContainerView
)
```

## 自定义外观

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

## RTL / 阿语

业务侧正常设置系统方向即可：

```swift
UIView.appearance().semanticContentAttribute = .forceRightToLeft
```

`ZWBSegmentedMenuView` 内部会自动处理：

- collectionView 方向翻转
- cell 内容翻转
- badge leading / trailing 翻转
- 选中背景图、文字放大、图片缩放保持自然

## Demo

项目内置 demo，包含：

- 礼物菜单预设
- 文本自适应宽度
- 靠左 / 居中 / 靠右
- 发现页图文混排
- 中文 / 阿语方向切换

