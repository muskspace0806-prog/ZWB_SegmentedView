//
//  DiscoverMixedDemoViewController.swift
//  ZWB_SegmentedView
//

import UIKit

/// 发现页图文混排示例，完整展示图片和文字菜单混合配置。
final class DiscoverMixedDemoViewController: UIViewController {
    private let titleLabel = UILabel()
    private let selectedLabel = UILabel()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private var demoViews: [UIView] = []
    private var bindings: [ZWBSegmentedMenuBinding] = []
    private var listDataSources: [DemoListDataSource] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DemoColor.background
        navigationItem.title = "发现页图文混排"
        navigationItem.backButtonDisplayMode = .minimal
        setupHeader()
        setupScrollView()
        setupDiscoverMixedMenu()
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
        titleLabel.textAlignment = view.effectiveUserInterfaceLayoutDirection == .rightToLeft ? .right : .left
        selectedLabel.textAlignment = view.effectiveUserInterfaceLayoutDirection == .rightToLeft ? .right : .left
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

    /// 设置页面标题和当前选中提示。
    private func setupHeader() {
        titleLabel.text = "发现页图文混排"
        titleLabel.textColor = DemoColor.primaryText
        titleLabel.font = .boldSystemFont(ofSize: 24)
        selectedLabel.text = "当前选中：0"
        selectedLabel.textColor = DemoColor.secondaryText
        selectedLabel.font = .systemFont(ofSize: 14)
        view.addSubview(titleLabel)
        view.addSubview(selectedLabel)
    }

    /// 设置滚动容器。
    private func setupScrollView() {
        scrollView.backgroundColor = .clear
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
    }

    /// 构建发现页图文混排菜单。
    private func setupDiscoverMixedMenu() {
        let items = discoverItems()
        let card = DemoMenuCardView(title: "发现页混排菜单", preferredHeight: 360)
        let segmentedView = JXSegmentedView()
        let menuView = ZWBSegmentedMenuView()
        let listDataSource = DemoListDataSource(items: items)
        let listContainerView = JXSegmentedListContainerView(dataSource: listDataSource)
        listDataSources.append(listDataSource)

        menuView.appearance = .discover(selectedBackgroundImage: UIImage(named: "menu_bg"))
        menuView.backgroundColor = .clear

        card.contentView.addSubview(segmentedView)
        card.contentView.addSubview(menuView)
        listContainerView.backgroundColor = UIColor(red: 0.97, green: 0.98, blue: 1.00, alpha: 1)
        listContainerView.layer.cornerRadius = 8
        listContainerView.layer.masksToBounds = true
        card.contentView.addSubview(listContainerView)
        card.layoutContent = { bounds in
            segmentedView.frame = CGRect(x: 8, y: 8, width: 1, height: 1)
            menuView.frame = CGRect(x: 8, y: 10, width: bounds.width - 16, height: 58)
            listContainerView.frame = CGRect(
                x: 8,
                y: menuView.frame.maxY + 12,
                width: bounds.width - 16,
                height: max(0, bounds.height - menuView.frame.maxY - 20)
            )
        }

        let binding = segmentedView.zwb_bindCustomMenu(menuView, items: items, listContainer: listContainerView) { [weak self] index in
            let title = items[index].title.isEmpty ? "图片项" : items[index].title
            self?.selectedLabel.text = "当前选中：\(index) - \(title)"
        }
        bindings.append(binding)
        contentView.addSubview(card)
        demoViews.append(card)
    }

    /// 发现页图文混排示例数据。
    private func discoverItems() -> [ZWBMenuItem] {
        [
            ZWBMenuItem(title: "发现"),
            ZWBMenuItem(normalImage: UIImage(named: "live_activity_fr_select"), selectedImage: UIImage(named: "live_activity_fr_select")),
            ZWBMenuItem(title: "动态")
        ]
    }
}
