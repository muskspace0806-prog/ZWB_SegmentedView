//
//  CustomCellDemoViewController.swift
//  ZWB_SegmentedView
//

import UIKit

/// 自定义 cell 示例，完整展示业务 cell 接入 ZWBSegmentedMenuView 的方式。
final class CustomCellDemoViewController: UIViewController {
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
        navigationItem.title = "自定义 Cell"
        navigationItem.backButtonDisplayMode = .minimal
        setupHeader()
        setupScrollView()
        setupCustomCellMenu()
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
        titleLabel.text = "自定义 Cell"
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

    /// 构建自定义 cell 菜单，容器仍然负责点击、滚动和页面联动。
    private func setupCustomCellMenu() {
        let items = customCellItems()
        let card = DemoMenuCardView(title: "业务自定义 Cell", preferredHeight: 360)
        let segmentedView = JXSegmentedView()
        let menuView = ZWBSegmentedMenuView()
        let listDataSource = DemoListDataSource(items: items)
        let listContainerView = JXSegmentedListContainerView(dataSource: listDataSource)
        listDataSources.append(listDataSource)

        menuView.backgroundColor = DemoColor.panel
        menuView.layer.cornerRadius = 8
        menuView.layer.masksToBounds = true
        menuView.appearance = ZWBSegmentedMenuAppearance(
            normalTextColor: UIColor(white: 1, alpha: 0.58),
            selectedTextColor: UIColor(red: 1.00, green: 0.25, blue: 0.45, alpha: 1),
            textFont: .systemFont(ofSize: 13, weight: .medium),
            selectedTextFont: .systemFont(ofSize: 13, weight: .semibold),
            indicatorColor: .clear,
            indicatorSize: .zero,
            itemHorizontalPadding: 0,
            minimumItemWidth: 1,
            itemSpacing: 8,
            contentInsets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        )
        // 注册业务自定义 cell，外部只提供 cell 类型，数据和选中态由协议方法统一接收。
        menuView.register(DemoCustomMenuCell.self, reuseIdentifier: DemoCustomMenuCell.reuseIdentifier)
        // 自定义 cell 尺寸由业务决定，未选中和选中返回同一宽度，避免选中时宽度变化导致卡顿。
        menuView.itemSizeProvider = { item, _, containerSize, _ in
            // 自适应宽度尺寸
            let baseWidth = max(66, ceil((item.title as NSString).size(withAttributes: [.font: UIFont.systemFont(ofSize: 14, weight: .semibold)]).width + 40))
            return CGSize(width: baseWidth, height: containerSize.height)
            // 固定尺寸
//            return CGSize(width: 100 , height: containerSize.height)
        }

        card.contentView.addSubview(segmentedView)
        card.contentView.addSubview(menuView)
        listContainerView.backgroundColor = UIColor(red: 0.97, green: 0.98, blue: 1.00, alpha: 1)
        listContainerView.layer.cornerRadius = 8
        listContainerView.layer.masksToBounds = true
        card.contentView.addSubview(listContainerView)
        card.layoutContent = { bounds in
            segmentedView.frame = CGRect(x: 8, y: 8, width: 1, height: 1)
            menuView.frame = CGRect(x: 8, y: 10, width: bounds.width - 16, height: 50)
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

    /// 自定义 cell 示例数据，包含普通文本和 leading 角标。
    private func customCellItems() -> [ZWBMenuItem] {
        [
            ZWBMenuItem(title: "全部", badgeImage: badgeImage(color: .systemPink), badgePlacement: .leadingCenter),
            ZWBMenuItem(title: "热门"),
            ZWBMenuItem(title: "背包"),
            ZWBMenuItem(title: "活动"),
            ZWBMenuItem(title: "SVGA")
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

/// 自定义菜单 cell，实现协议后即可接收容器下发的数据和选中进度。
private final class DemoCustomMenuCell: UICollectionViewCell, ZWBSegmentedMenuCellConfigurable {
    static let reuseIdentifier = "DemoCustomMenuCell"

    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let badgeImageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        badgeImageView.image = nil
        badgeImageView.isHidden = true
        applyProgressStyle(0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.frame = bounds.insetBy(dx: 4, dy: 7)
        // 标题左右内边距和自适应宽度计算保持一致，避免未选中态文本被提前省略。
        titleLabel.frame = containerView.bounds.inset(by: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
        badgeImageView.frame = CGRect(x: 2, y: (bounds.height - 16) / 2, width: 16, height: 16)
    }

    /// 基础数据赋值，只处理标题和角标，选中态动画交给 updateSelectionProgress 统一接收。
    func configure(item: ZWBMenuItem, isSelected: Bool, appearance: ZWBSegmentedMenuAppearance) {
        titleLabel.text = item.title
        badgeImageView.image = item.badgeImage
        badgeImageView.isHidden = item.badgeImage == nil
        updateSelectionProgress(isSelected ? 1 : 0, item: item, appearance: appearance)
    }

    /// 根据容器传入的选中进度更新 UI，点击选中和页面滑动都会走到这里。
    func updateSelectionProgress(_ progress: CGFloat, item: ZWBMenuItem, appearance: ZWBSegmentedMenuAppearance) {
        applyProgressStyle(progress)
    }

    /// 内部选中态样式更新，复用时也可以直接恢复到未选中样式。
    private func applyProgressStyle(_ progress: CGFloat) {
        let p = min(1, max(0, progress))
        let normalColor = UIColor(white: 1, alpha: 0.58)
        let selectedColor = UIColor(red: 1.00, green: 0.25, blue: 0.45, alpha: 1)
        titleLabel.textColor = interpolateColor(from: normalColor, to: selectedColor, progress: p)
        titleLabel.font = .systemFont(ofSize: 13 + p, weight: p > 0.5 ? .semibold : .medium)
        containerView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.08 + p * 0.14)
        containerView.transform = CGAffineTransform(scaleX: 1 + p * 0.06, y: 1 + p * 0.06)
    }

    /// 初始化自定义 cell 内部控件。
    private func setupUI() {
        contentView.backgroundColor = .clear
        containerView.layer.cornerRadius = 7
        containerView.layer.masksToBounds = true
        titleLabel.textAlignment = .center
        titleLabel.font = .systemFont(ofSize: 13, weight: .medium)
        // demo 展示完整标题，实际业务可按需要改回 byTruncatingTail。
        titleLabel.lineBreakMode = .byClipping
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.9
        badgeImageView.contentMode = .scaleAspectFit
        badgeImageView.isHidden = true
        contentView.addSubview(containerView)
        contentView.addSubview(badgeImageView)
        containerView.addSubview(titleLabel)
    }

    /// demo 内部颜色插值，避免依赖组件内部 fileprivate 工具方法。
    private func interpolateColor(from: UIColor, to: UIColor, progress: CGFloat) -> UIColor {
        var fromRed: CGFloat = 0
        var fromGreen: CGFloat = 0
        var fromBlue: CGFloat = 0
        var fromAlpha: CGFloat = 0
        var toRed: CGFloat = 0
        var toGreen: CGFloat = 0
        var toBlue: CGFloat = 0
        var toAlpha: CGFloat = 0

        from.getRed(&fromRed, green: &fromGreen, blue: &fromBlue, alpha: &fromAlpha)
        to.getRed(&toRed, green: &toGreen, blue: &toBlue, alpha: &toAlpha)

        return UIColor(
            red: fromRed + (toRed - fromRed) * progress,
            green: fromGreen + (toGreen - fromGreen) * progress,
            blue: fromBlue + (toBlue - fromBlue) * progress,
            alpha: fromAlpha + (toAlpha - fromAlpha) * progress
        )
    }
}
