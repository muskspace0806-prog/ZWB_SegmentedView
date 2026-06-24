//
//  PresetGiftDemoViewController.swift
//  ZWB_SegmentedView
//

import UIKit

/// 礼物菜单预设示例，完整展示 ZWBSegmentedMenuView 的基础接入流程。
final class PresetGiftDemoViewController: UIViewController {
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
        navigationItem.title = "礼物菜单预设"
        navigationItem.backButtonDisplayMode = .minimal
        setupHeader()
        setupScrollView()
        setupGiftMenu()
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
        titleLabel.text = "礼物菜单预设"
        titleLabel.textColor = DemoColor.primaryText
        titleLabel.font = .boldSystemFont(ofSize: 24)
        selectedLabel.text = "当前选中：0"
        selectedLabel.textColor = DemoColor.secondaryText
        selectedLabel.font = .systemFont(ofSize: 14)
        view.addSubview(titleLabel)
        view.addSubview(selectedLabel)
    }

    /// 设置滚动容器，后续示例卡片都添加到 contentView。
    private func setupScrollView() {
        scrollView.backgroundColor = .clear
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
    }

    /// 构建礼物菜单预设样式。
    private func setupGiftMenu() {
        let items = giftItems()
        let card = DemoMenuCardView(title: "礼物菜单预设", preferredHeight: 300)
        let segmentedView = JXSegmentedView()
        let menuView = ZWBSegmentedMenuView()
        let listDataSource = DemoListDataSource(items: items)
        let listContainerView = JXSegmentedListContainerView(dataSource: listDataSource)
        listDataSources.append(listDataSource)

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

        card.contentView.addSubview(segmentedView)
        card.contentView.addSubview(menuView)
        listContainerView.backgroundColor = UIColor(red: 0.97, green: 0.98, blue: 1.00, alpha: 1)
        listContainerView.layer.cornerRadius = 8
        listContainerView.layer.masksToBounds = true
        card.contentView.addSubview(listContainerView)
        card.layoutContent = { bounds in
            segmentedView.frame = CGRect(x: 8, y: 8, width: 1, height: 1)
            menuView.frame = CGRect(x: 8, y: 10, width: bounds.width - 16, height: 44)
            listContainerView.frame = CGRect(
                x: 8,
                y: menuView.frame.maxY + 12,
                width: bounds.width - 16,
                height: max(0, bounds.height - menuView.frame.maxY - 20)
            )
        }

        let binding = segmentedView.zwb_bindCustomMenu(menuView, items: items, listContainer: listContainerView) { [weak self] index in
            self?.selectedLabel.text = "当前选中：\(index) - \(items[index].title)"
        }
        bindings.append(binding)
        contentView.addSubview(card)
        demoViews.append(card)
    }

    /// 礼物菜单示例数据。
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

    /// 生成示例角标图片。
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
