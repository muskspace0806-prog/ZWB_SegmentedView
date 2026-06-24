//
//  StyleDemoViewController.swift
//  ZWB_SegmentedView
//

import UIKit

enum SegmentedStyleDemo {
    case presetGift
    case textAdaptive
    case alignment
    case discoverMixed

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
        }
    }

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
        }
    }
}

final class StyleDemoViewController: UIViewController {
    private let style: SegmentedStyleDemo
    private let titleLabel = UILabel()
    private let selectedLabel = UILabel()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private var demoViews: [UIView] = []
    private var bindings: [ZWBSegmentedMenuBinding] = []
    private var jxDataSources: [JXSegmentedBaseDataSource] = []
    private var listDataSources: [DemoListDataSource] = []

    init(style: SegmentedStyleDemo) {
        self.style = style
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DemoColor.background
        navigationItem.title = style.title
        navigationItem.backButtonDisplayMode = .minimal
        setupHeader()
        setupScrollView()
        buildDemo()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let safe = view.safeAreaInsets
        titleLabel.frame = CGRect(x: 20, y: safe.top + 16, width: view.bounds.width - 40, height: 32)
        selectedLabel.frame = CGRect(x: 20, y: titleLabel.frame.maxY + 6, width: view.bounds.width - 40, height: 20)
        let isRTL = view.effectiveUserInterfaceLayoutDirection == .rightToLeft
        titleLabel.textAlignment = isRTL ? .right : .left
        selectedLabel.textAlignment = isRTL ? .right : .left

        scrollView.frame = CGRect(
            x: 0,
            y: selectedLabel.frame.maxY + 14,
            width: view.bounds.width,
            height: max(0, view.bounds.height - selectedLabel.frame.maxY - 14)
        )

        var y: CGFloat = 10
        let width = view.bounds.width - 32
        for demoView in demoViews {
            let height = (demoView as? DemoMenuCardView)?.preferredHeight ?? 84
            demoView.frame = CGRect(x: 16, y: y, width: width, height: height)
            y += height + 18
        }
        contentView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: y + 12)
        scrollView.contentSize = contentView.bounds.size
    }

    private func setupHeader() {
        titleLabel.text = style.title
        titleLabel.textColor = DemoColor.primaryText
        titleLabel.font = .boldSystemFont(ofSize: 24)
        titleLabel.textAlignment = view.effectiveUserInterfaceLayoutDirection == .rightToLeft ? .right : .left
        selectedLabel.text = "当前选中：0"
        selectedLabel.textColor = DemoColor.secondaryText
        selectedLabel.font = .systemFont(ofSize: 14)
        selectedLabel.textAlignment = view.effectiveUserInterfaceLayoutDirection == .rightToLeft ? .right : .left
        view.addSubview(titleLabel)
        view.addSubview(selectedLabel)
    }

    private func setupScrollView() {
        scrollView.backgroundColor = .clear
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
    }

    private func buildDemo() {
        switch style {
        case .presetGift:
            addMenuCard(title: "礼物菜单预设", items: giftItems()) { menuView in
                menuView.appearance = ZWBSegmentedMenuAppearance(
                    normalTextColor: UIColor(white: 1, alpha: 0.55),
                    selectedTextColor: .systemPink,
                    textFont: .systemFont(ofSize: 15),
                    selectedTextFont: .boldSystemFont(ofSize: 15),
                    indicatorColor: .systemPink,
                    indicatorSize: CGSize(width: 28, height: 2),
                    itemHorizontalPadding: 16,
                    minimumItemWidth: 64,
                    itemSpacing: 0,
                    contentInsets: UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
                )
                menuView.backgroundColor = DemoColor.panel
                menuView.layer.cornerRadius = 8
                menuView.layer.masksToBounds = true
            }
        case .textAdaptive:
            addMenuCard(title: "内容宽度 + cell 间距", items: giftItems()) { menuView in
                menuView.appearance = ZWBSegmentedMenuAppearance(
                    normalTextColor: UIColor(white: 1, alpha: 0.55),
                    selectedTextColor: UIColor(red: 0.27, green: 0.95, blue: 0.55, alpha: 1),
                    textFont: .systemFont(ofSize: 15),
                    selectedTextFont: .boldSystemFont(ofSize: 17),
                    indicatorColor: UIColor(red: 0.27, green: 0.95, blue: 0.55, alpha: 1),
                    indicatorSize: CGSize(width: 32, height: 3),
                    itemHorizontalPadding: 22,
                    minimumItemWidth: 46,
                    itemSpacing: 8,
                    contentInsets: UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
                )
                menuView.backgroundColor = DemoColor.panel
                menuView.layer.cornerRadius = 8
                menuView.layer.masksToBounds = true
            }
        case .alignment:
            addJXCard(title: "JX 靠左", alignment: .leading(inset: 12))
            addJXCard(title: "JX 居中", alignment: .center(inset: 12))
            addJXCard(title: "JX 靠右", alignment: .trailing(inset: 12))
        case .discoverMixed:
            addMenuCard(title: "发现页混排菜单", items: discoverItems(), height: 360) { menuView in
                menuView.appearance = .discover(selectedBackgroundImage: UIImage(named: "menu_bg"))
                menuView.backgroundColor = .clear
            }
        }
    }

    private func addMenuCard(
        title: String,
        items: [ZWBMenuItem],
        height: CGFloat = 300,
        configure: (ZWBSegmentedMenuView) -> Void
    ) {
        let card = DemoMenuCardView(title: title, preferredHeight: height)
        let segmentedView = JXSegmentedView()
        let menuView = ZWBSegmentedMenuView()
        let listDataSource = DemoListDataSource(items: items)
        let listContainerView = JXSegmentedListContainerView(dataSource: listDataSource)
        listDataSources.append(listDataSource)
        configure(menuView)
        card.contentView.addSubview(segmentedView)
        card.contentView.addSubview(menuView)
        listContainerView.backgroundColor = UIColor(red: 0.97, green: 0.98, blue: 1.00, alpha: 1)
        listContainerView.layer.cornerRadius = 8
        listContainerView.layer.masksToBounds = true
        card.contentView.addSubview(listContainerView)
        card.layoutContent = { bounds in
            segmentedView.frame = CGRect(x: 8, y: 8, width: 1, height: 1)
            let menuHeight: CGFloat = height > 330 ? 58 : 44
            menuView.frame = CGRect(x: 8, y: 10, width: bounds.width - 16, height: menuHeight)
            listContainerView.frame = CGRect(
                x: 8,
                y: menuView.frame.maxY + 12,
                width: bounds.width - 16,
                height: max(0, bounds.height - menuView.frame.maxY - 20)
            )
        }
        let binding = segmentedView.zwb_bindCustomMenu(menuView, items: items, listContainer: listContainerView) { [weak self] index in
            self?.selectedLabel.text = "当前选中：\(index) - \(items[index].title.isEmpty ? "图片项" : items[index].title)"
        }
        bindings.append(binding)
        contentView.addSubview(card)
        demoViews.append(card)
    }

    private func addJXCard(title: String, alignment: ZWBSegmentedAlignment) {
        let items = [
            ZWBMenuItem(title: "全部"),
            ZWBMenuItem(title: "幸运盒子"),
            ZWBMenuItem(title: "VIP"),
            ZWBMenuItem(title: "名人")
        ]
        let card = DemoMenuCardView(title: title, preferredHeight: 260)
        let segmentedView = JXSegmentedView()
        let listDataSource = DemoListDataSource(items: items)
        let listContainerView = JXSegmentedListContainerView(dataSource: listDataSource)
        let dataSource = JXSegmentedTitleDataSource()
        dataSource.titles = items.map { $0.title }
        jxDataSources.append(dataSource)
        listDataSources.append(listDataSource)
        segmentedView.zwb_apply(
            ZWBSegmentedConfiguration(
                widthMode: .content(padding: 18, minWidth: 46),
                spacingMode: .fixed(6),
                alignment: alignment,
                indicatorMode: .content(extra: 4, height: 3, color: .systemPink),
                titleStyle: ZWBSegmentedTitleStyle(
                    normalColor: UIColor(white: 1, alpha: 0.55),
                    selectedColor: UIColor(red: 1.00, green: 0.23, blue: 0.45, alpha: 1),
                    normalFont: .systemFont(ofSize: 14),
                    selectedFont: .boldSystemFont(ofSize: 15)
                )
            ),
            dataSource: dataSource
        )
        segmentedView.listContainer = listContainerView
        segmentedView.layer.cornerRadius = 8
        segmentedView.layer.masksToBounds = true
        segmentedView.backgroundColor = DemoColor.panel
        listContainerView.backgroundColor = UIColor(red: 0.97, green: 0.98, blue: 1.00, alpha: 1)
        listContainerView.layer.cornerRadius = 8
        listContainerView.layer.masksToBounds = true
        card.contentView.addSubview(segmentedView)
        card.contentView.addSubview(listContainerView)
        card.layoutContent = { bounds in
            segmentedView.frame = CGRect(x: 8, y: 10, width: bounds.width - 16, height: 44)
            listContainerView.frame = CGRect(
                x: 8,
                y: segmentedView.frame.maxY + 12,
                width: bounds.width - 16,
                height: max(0, bounds.height - segmentedView.frame.maxY - 20)
            )
        }
        contentView.addSubview(card)
        demoViews.append(card)
    }

    private func giftItems() -> [ZWBMenuItem] {
        [
            ZWBMenuItem(title: "通用"),
            ZWBMenuItem(title: "幸运盒子", badgeImage: badgeImage(color: .systemOrange)),
            ZWBMenuItem(title: "幸运"),
            ZWBMenuItem(title: "国家"),
            ZWBMenuItem(title: "VIP"),
            ZWBMenuItem(title: "名人")
        ]
    }

    private func discoverItems() -> [ZWBMenuItem] {
        [
            ZWBMenuItem(title: "发现"),
            ZWBMenuItem(normalImage: UIImage(named: "live_activity_fr_select"), selectedImage: UIImage(named: "live_activity_fr_select")),
            ZWBMenuItem(title: "动态")
        ]
    }

    private func badgeImage(color: UIColor) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 16, height: 16))
        return renderer.image { context in
            color.setFill()
            context.cgContext.fillEllipse(in: CGRect(x: 2, y: 2, width: 12, height: 12))
            UIColor.white.setFill()
            context.cgContext.fillEllipse(in: CGRect(x: 6, y: 6, width: 4, height: 4))
        }
    }
}

private final class DemoListDataSource: NSObject, JXSegmentedListContainerViewDataSource {
    private let items: [ZWBMenuItem]

    init(items: [ZWBMenuItem]) {
        self.items = items
    }

    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        items.count
    }

    func listContainerView(
        _ listContainerView: JXSegmentedListContainerView,
        initListAt index: Int
    ) -> JXSegmentedListContainerViewListDelegate {
        let item = items[index]
        let title = item.title.isEmpty ? "活动图片页" : item.title
        return DemoListView(title: title, index: index)
    }
}

private final class DemoMenuCardView: UIView {
    let contentView = UIView()
    let preferredHeight: CGFloat
    var layoutContent: ((CGRect) -> Void)?

    private let titleLabel = UILabel()

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
