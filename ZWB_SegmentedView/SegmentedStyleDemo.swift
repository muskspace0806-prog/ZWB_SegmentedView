//
//  SegmentedStyleDemo.swift
//  ZWB_SegmentedView
//

import UIKit

/// 首页示例类型，只负责首页展示文案和跳转目标。
enum SegmentedStyleDemo {
    case presetGift
    case textAdaptive
    case alignment
    case discoverMixed
    /// 自定义 UICollectionViewCell 接入 ZWBSegmentedMenuView 的示例。
    case customCell

    /// 首页列表标题。
    var title: String {
        switch self {
        case .presetGift:
            return "礼物菜单预设"
        case .textAdaptive:
            return "文本自适应宽度"
        case .alignment:
            return "靠左 / 居中 / 靠右"
        case .discoverMixed:
            return "发现页图文混排"
        case .customCell:
            return "自定义 Cell"
        }
    }

    /// 首页列表说明。
    var detail: String {
        switch self {
        case .presetGift:
            return "一行配置礼物场景常用样式"
        case .textAdaptive:
            return "文本宽度、最小宽度、内部间距"
        case .alignment:
            return "同一组数据展示不同对齐方式"
        case .discoverMixed:
            return "menu_bg + 活动图片 + 自然放大选中态"
        case .customCell:
            return "业务 cell 接入容器，复用点击与滑动联动"
        }
    }

    /// 首页点击后创建对应示例 Controller，每个 Controller 都是独立页面类。
    func makeController() -> UIViewController {
        switch self {
        case .presetGift:
            return PresetGiftDemoViewController()
        case .textAdaptive:
            return TextAdaptiveDemoViewController()
        case .alignment:
            return AlignmentDemoViewController()
        case .discoverMixed:
            return DiscoverMixedDemoViewController()
        case .customCell:
            return CustomCellDemoViewController()
        }
    }
}

/// demo 页面使用的列表容器数据源，避免每个示例重复实现 JXSegmentedListContainerViewDataSource。
final class DemoListDataSource: NSObject, JXSegmentedListContainerViewDataSource {
    private let items: [ZWBMenuItem]

    /// 保存当前菜单数据，用于创建对应页面。
    init(items: [ZWBMenuItem]) {
        self.items = items
    }

    /// 返回页面数量。
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        items.count
    }

    /// 创建每个菜单项对应的内容页。
    func listContainerView(
        _ listContainerView: JXSegmentedListContainerView,
        initListAt index: Int
    ) -> JXSegmentedListContainerViewListDelegate {
        let item = items[index]
        let title = item.title.isEmpty ? "活动图片页" : item.title
        return DemoListView(title: title, index: index)
    }
}

/// demo 页面卡片容器，只负责标题、边框和内部内容区域布局。
final class DemoMenuCardView: UIView {
    let contentView = UIView()
    let preferredHeight: CGFloat
    var layoutContent: ((CGRect) -> Void)?

    private let titleLabel = UILabel()

    /// 创建带标题的 demo 卡片。
    init(title: String, preferredHeight: CGFloat = 84) {
        self.preferredHeight = preferredHeight
        super.init(frame: .zero)
        backgroundColor = DemoColor.card
        layer.cornerRadius = 8
        layer.masksToBounds = true
        layer.borderWidth = 1
        layer.borderColor = DemoColor.stroke.cgColor
        titleLabel.text = title
        titleLabel.textColor = DemoColor.secondaryText
        titleLabel.font = .systemFont(ofSize: 13, weight: .medium)
        addSubview(titleLabel)
        addSubview(contentView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.textAlignment = effectiveUserInterfaceLayoutDirection == .rightToLeft ? .right : .left
        titleLabel.frame = CGRect(x: 14, y: 9, width: bounds.width - 28, height: 18)
        contentView.frame = CGRect(x: 6, y: titleLabel.frame.maxY + 4, width: bounds.width - 12, height: bounds.height - titleLabel.frame.maxY - 10)
        layoutContent?(contentView.bounds)
    }
}
