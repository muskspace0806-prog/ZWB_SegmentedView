//
//  AlignmentDemoViewController.swift
//  ZWB_SegmentedView
//

import UIKit

/// 对齐方式示例，完整展示靠左、居中、靠右三种配置。
final class AlignmentDemoViewController: UIViewController {
    private let titleLabel = UILabel()
    private let selectedLabel = UILabel()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private var demoViews: [UIView] = []
    private var jxDataSources: [JXSegmentedBaseDataSource] = []
    private var listDataSources: [DemoListDataSource] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DemoColor.background
        navigationItem.title = "靠左 / 居中 / 靠右"
        navigationItem.backButtonDisplayMode = .minimal
        setupHeader()
        setupScrollView()
        setupJXCard(title: "JX 靠左", alignment: .leading(inset: 12))
        setupJXCard(title: "JX 居中", alignment: .center(inset: 12))
        setupJXCard(title: "JX 靠右", alignment: .trailing(inset: 12))
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
        titleLabel.text = "靠左 / 居中 / 靠右"
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

    /// 构建单个 JXSegmentedView 对齐示例卡片。
    private func setupJXCard(title: String, alignment: ZWBSegmentedAlignment) {
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
}
