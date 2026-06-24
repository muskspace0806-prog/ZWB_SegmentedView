//
//  ZWBSegmentedMenuView.swift
//  ZWB_SegmentedView
//

import UIKit

/// Selection background behavior for custom menu cells.
public enum ZWBSegmentedMenuSelectionBackgroundMode {
    /// No selected background image.
    case none
    /// Draw the image centered at its original size.
    case original
    /// Stretch the image to the selected cell bounds.
    case fill(insets: UIEdgeInsets)
}

/// Scale behavior used by image-only menu items.
public struct ZWBSegmentedMenuImageScale {
    public var normal: CGFloat
    public var selected: CGFloat

    public init(normal: CGFloat = 0.85, selected: CGFloat = 1.0) {
        self.normal = normal
        self.selected = selected
    }
}

/// Appearance options for `ZWBSegmentedMenuView`.
///
/// The defaults match the original text-menu behavior. The discover-style
/// preset turns on selected background image, larger selected text and image
/// scaling for a mixed text/image menu.
public struct ZWBSegmentedMenuAppearance {
    public var normalTextColor: UIColor
    public var selectedTextColor: UIColor
    public var textFont: UIFont
    public var selectedTextFont: UIFont
    public var indicatorColor: UIColor
    public var indicatorSize: CGSize
    public var indicatorBottomInset: CGFloat
    public var itemHorizontalPadding: CGFloat
    public var minimumItemWidth: CGFloat
    public var itemSpacing: CGFloat
    public var contentInsets: UIEdgeInsets
    public var selectedBackgroundImage: UIImage?
    public var selectedBackgroundMode: ZWBSegmentedMenuSelectionBackgroundMode
    public var imageScale: ZWBSegmentedMenuImageScale
    public var scrollsSelectedItemToCenter: Bool

    public init(
        normalTextColor: UIColor = UIColor(white: 0.55, alpha: 1),
        selectedTextColor: UIColor = UIColor(red: 1, green: 0, blue: 1, alpha: 1),
        textFont: UIFont = .systemFont(ofSize: 15),
        selectedTextFont: UIFont = .boldSystemFont(ofSize: 15),
        indicatorColor: UIColor = UIColor(red: 1, green: 0, blue: 1, alpha: 1),
        indicatorSize: CGSize = CGSize(width: 28, height: 2),
        indicatorBottomInset: CGFloat = 2,
        itemHorizontalPadding: CGFloat = 16,
        minimumItemWidth: CGFloat = 64,
        itemSpacing: CGFloat = 0,
        contentInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14),
        selectedBackgroundImage: UIImage? = nil,
        selectedBackgroundMode: ZWBSegmentedMenuSelectionBackgroundMode = .none,
        imageScale: ZWBSegmentedMenuImageScale = ZWBSegmentedMenuImageScale(),
        scrollsSelectedItemToCenter: Bool = true
    ) {
        self.normalTextColor = normalTextColor
        self.selectedTextColor = selectedTextColor
        self.textFont = textFont
        self.selectedTextFont = selectedTextFont
        self.indicatorColor = indicatorColor
        self.indicatorSize = indicatorSize
        self.indicatorBottomInset = indicatorBottomInset
        self.itemHorizontalPadding = itemHorizontalPadding
        self.minimumItemWidth = minimumItemWidth
        self.itemSpacing = itemSpacing
        self.contentInsets = contentInsets
        self.selectedBackgroundImage = selectedBackgroundImage
        self.selectedBackgroundMode = selectedBackgroundMode
        self.imageScale = imageScale
        self.scrollsSelectedItemToCenter = scrollsSelectedItemToCenter
    }

    public static func discover(
        selectedBackgroundImage: UIImage?,
        normalColor: UIColor = UIColor(white: 0.58, alpha: 1),
        selectedColor: UIColor = UIColor(red: 0.10, green: 0.00, blue: 0.10, alpha: 1)
    ) -> ZWBSegmentedMenuAppearance {
        ZWBSegmentedMenuAppearance(
            normalTextColor: normalColor,
            selectedTextColor: selectedColor,
            textFont: .systemFont(ofSize: 18, weight: .semibold),
            selectedTextFont: .systemFont(ofSize: 22, weight: .semibold),
            indicatorColor: .clear,
            indicatorSize: .zero,
            itemHorizontalPadding: 4,
            minimumItemWidth: 1,
            itemSpacing: 16,
            contentInsets: UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4),
            selectedBackgroundImage: selectedBackgroundImage,
            selectedBackgroundMode: .original,
            imageScale: ZWBSegmentedMenuImageScale(normal: 0.85, selected: 1.0)
        )
    }
}

public final class ZWBSegmentedMenuView: UIView {
    public var onSelect: ((Int) -> Void)?

    public var appearance: ZWBSegmentedMenuAppearance = ZWBSegmentedMenuAppearance() {
        didSet { applyAppearance(needsReload: true) }
    }

    public var normalTextColor: UIColor {
        get { appearance.normalTextColor }
        set { appearance.normalTextColor = newValue }
    }

    public var selectedTextColor: UIColor {
        get { appearance.selectedTextColor }
        set { appearance.selectedTextColor = newValue }
    }

    public var textFont: UIFont {
        get { appearance.textFont }
        set { appearance.textFont = newValue }
    }

    public var selectedTextFont: UIFont {
        get { appearance.selectedTextFont }
        set { appearance.selectedTextFont = newValue }
    }

    public var itemHorizontalPadding: CGFloat {
        get { appearance.itemHorizontalPadding }
        set { appearance.itemHorizontalPadding = newValue }
    }

    public var minimumItemWidth: CGFloat {
        get { appearance.minimumItemWidth }
        set { appearance.minimumItemWidth = newValue }
    }

    public var itemSpacing: CGFloat {
        get { appearance.itemSpacing }
        set { appearance.itemSpacing = newValue }
    }

    public var contentInsets: UIEdgeInsets {
        get { appearance.contentInsets }
        set { appearance.contentInsets = newValue }
    }

    public var indicatorColor: UIColor {
        get { appearance.indicatorColor }
        set { appearance.indicatorColor = newValue }
    }

    public var indicatorSize: CGSize {
        get { appearance.indicatorSize }
        set { appearance.indicatorSize = newValue }
    }

    public var selectedBackgroundImage: UIImage? {
        get { appearance.selectedBackgroundImage }
        set {
            appearance.selectedBackgroundImage = newValue
            if newValue != nil, case .none = appearance.selectedBackgroundMode {
                appearance.selectedBackgroundMode = .original
            }
        }
    }

    public private(set) var selectedIndex: Int = 0

    private var items: [ZWBMenuItem] = []

    private lazy var flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        return layout
    }()

    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        view.backgroundColor = .clear
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        view.alwaysBounceHorizontal = true
        if #available(iOS 11.0, *) {
            view.contentInsetAdjustmentBehavior = .never
        }
        view.dataSource = self
        view.delegate = self
        view.register(ZWBSegmentedMenuCell.self, forCellWithReuseIdentifier: ZWBSegmentedMenuCell.reuseIdentifier)
        return view
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(collectionView)
        applyLayoutDirection()
        applyAppearance(needsReload: false)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addSubview(collectionView)
        applyLayoutDirection()
        applyAppearance(needsReload: false)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        applyLayoutDirection()
        collectionView.frame = bounds
    }

    public func reload(items: [ZWBMenuItem], selectedIndex: Int = 0) {
        self.items = items
        self.selectedIndex = clamped(index: selectedIndex)
        applyLayoutDirection()
        collectionView.reloadData()
        scrollToSelected(animated: false)
    }

    public func select(index: Int, animated: Bool = true) {
        let targetIndex = clamped(index: index)
        let oldIndex = selectedIndex
        selectedIndex = targetIndex

        let changedIndexes = Set([oldIndex, targetIndex])
        if animated {
            updateVisibleCellsForSelection(indexes: changedIndexes)
        } else {
            collectionView.reloadData()
        }
        scrollToSelected(animated: animated)
    }

    /// Keeps the custom menu visually in sync with `JXSegmentedView` scroll
    /// progress. `percent` is 0 at `leftIndex` and 1 at `rightIndex`.
    public func updateScrollProgress(leftIndex: Int, rightIndex: Int, percent: CGFloat) {
        guard leftIndex >= 0, leftIndex < items.count,
              rightIndex >= 0, rightIndex < items.count else { return }

        CATransaction.begin()
        CATransaction.setDisableActions(true)

        for index in 0..<items.count {
            guard let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? ZWBSegmentedMenuCell else {
                continue
            }
            let progress: CGFloat
            if index == leftIndex {
                progress = 1 - percent
            } else if index == rightIndex {
                progress = percent
            } else {
                progress = 0
            }
            cell.applyProgress(progress, appearance: appearance, item: items[index])
        }

        CATransaction.commit()
    }

    private func applyAppearance(needsReload: Bool) {
        applyLayoutDirection()
        flowLayout.minimumLineSpacing = appearance.itemSpacing
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.sectionInset = appearance.contentInsets
        collectionView.collectionViewLayout.invalidateLayout()
        if needsReload { collectionView.reloadData() }
    }

    private func applyLayoutDirection() {
        collectionView.semanticContentAttribute = .forceLeftToRight
        collectionView.transform = isRightToLeftLayout ? CGAffineTransform(scaleX: -1, y: 1) : .identity
    }

    private var isRightToLeftLayout: Bool {
        if #available(iOS 10.0, *), effectiveUserInterfaceLayoutDirection == .rightToLeft {
            return true
        }
        return UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .rightToLeft ||
        UIView.userInterfaceLayoutDirection(for: UIView.appearance().semanticContentAttribute) == .rightToLeft
    }

    private func clamped(index: Int) -> Int {
        guard !items.isEmpty else { return 0 }
        return max(0, min(index, items.count - 1))
    }

    private func scrollToSelected(animated: Bool) {
        guard appearance.scrollsSelectedItemToCenter, !items.isEmpty else { return }
        collectionView.scrollToItem(
            at: IndexPath(item: selectedIndex, section: 0),
            at: .centeredHorizontally,
            animated: animated
        )
    }

    private func updateVisibleCellsForSelection(indexes: Set<Int>) {
        for index in indexes {
            guard index >= 0, index < items.count,
                  let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? ZWBSegmentedMenuCell else {
                continue
            }
            cell.configure(
                item: items[index],
                isSelected: index == selectedIndex,
                appearance: appearance
            )
        }

        for case let cell as ZWBSegmentedMenuCell in collectionView.visibleCells {
            guard let indexPath = collectionView.indexPath(for: cell), indexPath.item < items.count else {
                continue
            }
            let progress: CGFloat = indexPath.item == selectedIndex ? 1 : 0
            UIView.animate(
                withDuration: 0.28,
                delay: 0,
                usingSpringWithDamping: 0.78,
                initialSpringVelocity: 0.25,
                options: [.allowUserInteraction, .beginFromCurrentState]
            ) {
                cell.applyProgress(progress, appearance: self.appearance, item: self.items[indexPath.item])
            }
        }
    }

    private func itemWidth(for item: ZWBMenuItem, isSelected: Bool) -> CGFloat {
        if item.isImageOnly {
            let image = isSelected ? (item.selectedImage ?? item.normalImage) : item.normalImage
            return max(appearance.minimumItemWidth, ceil((image?.size.width ?? 0) + appearance.itemHorizontalPadding))
        }
        let font = isSelected ? appearance.selectedTextFont : appearance.textFont
        let textWidth = (item.title as NSString).size(withAttributes: [.font: font]).width
        let badgeWidth: CGFloat = item.badgeImage == nil ? 0 : 18
        return max(appearance.minimumItemWidth, ceil(textWidth + appearance.itemHorizontalPadding + badgeWidth))
    }
}

extension ZWBSegmentedMenuView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ZWBSegmentedMenuCell.reuseIdentifier,
            for: indexPath
        ) as! ZWBSegmentedMenuCell
        let isSelected = indexPath.item == selectedIndex
        cell.configure(item: items[indexPath.item], isSelected: isSelected, appearance: appearance)
        cell.setRightToLeftLayout(isRightToLeftLayout)
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item != selectedIndex else { return }
        onSelect?(indexPath.item)
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let selected = indexPath.item == selectedIndex
        return CGSize(width: itemWidth(for: items[indexPath.item], isSelected: selected), height: collectionView.bounds.height)
    }
}

private final class ZWBSegmentedMenuCell: UICollectionViewCell {
    static let reuseIdentifier = "ZWBSegmentedMenuCell"

    private let backgroundImageView = UIImageView()
    private let titleLabel = UILabel()
    private let indicatorView = UIView()
    private let badgeImageView = UIImageView()
    private let iconImageView = UIImageView()
    private let visualContentView = UIView()
    private var isRightToLeftContent = false

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
        backgroundImageView.image = nil
        backgroundImageView.alpha = 0
        titleLabel.text = nil
        badgeImageView.image = nil
        iconImageView.image = nil
        contentView.transform = .identity
        visualContentView.transform = .identity
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        visualContentView.frame = contentView.bounds
        let bounds = visualContentView.bounds
        backgroundImageView.center = CGPoint(x: bounds.midX, y: bounds.midY)
        titleLabel.sizeToFit()
        titleLabel.center = CGPoint(x: bounds.midX, y: bounds.midY)
        iconImageView.center = CGPoint(x: bounds.midX, y: bounds.midY)
        indicatorView.center = CGPoint(x: bounds.midX, y: bounds.maxY - indicatorView.bounds.height / 2 - indicatorBottomInset)
        badgeImageView.frame = badgeFrame(in: bounds)
    }

    private var indicatorBottomInset: CGFloat = 2
    private var badgePlacement: ZWBMenuItemBadgePlacement = .trailingTop

    func configure(item: ZWBMenuItem, isSelected: Bool, appearance: ZWBSegmentedMenuAppearance) {
        backgroundImageView.image = appearance.selectedBackgroundImage
        backgroundImageView.contentMode = .scaleAspectFit
        indicatorBottomInset = appearance.indicatorBottomInset
        badgePlacement = item.badgePlacement

        if item.isImageOnly {
            titleLabel.isHidden = true
            indicatorView.isHidden = true
            badgeImageView.isHidden = true
            iconImageView.isHidden = false
            iconImageView.image = isSelected ? (item.selectedImage ?? item.normalImage) : item.normalImage
            iconImageView.sizeToFit()
        } else {
            titleLabel.isHidden = false
            indicatorView.isHidden = appearance.indicatorSize == .zero
            badgeImageView.isHidden = item.badgeImage == nil
            iconImageView.isHidden = true

            titleLabel.text = item.title
            titleLabel.textAlignment = .center
            titleLabel.numberOfLines = 1
            badgeImageView.image = item.badgeImage
            badgeImageView.contentMode = .scaleAspectFit
            badgeImageView.frame.size = CGSize(width: 16, height: 16)
            indicatorView.backgroundColor = appearance.indicatorColor
            indicatorView.layer.cornerRadius = appearance.indicatorSize.height / 2
            indicatorView.bounds.size = appearance.indicatorSize
        }

        applyProgress(isSelected ? 1 : 0, appearance: appearance, item: item)
    }

    func setRightToLeftLayout(_ isRightToLeft: Bool) {
        isRightToLeftContent = isRightToLeft
        contentView.transform = isRightToLeft ? CGAffineTransform(scaleX: -1, y: 1) : .identity
        setNeedsLayout()
    }

    func applyProgress(_ progress: CGFloat, appearance: ZWBSegmentedMenuAppearance, item: ZWBMenuItem) {
        let p = min(1, max(0, progress))
        backgroundImageView.alpha = p

        if item.isImageOnly {
            iconImageView.image = p > 0.5 ? (item.selectedImage ?? item.normalImage) : item.normalImage
            let scale = interpolate(from: appearance.imageScale.normal, to: appearance.imageScale.selected, progress: p)
            visualContentView.transform = CGAffineTransform(scaleX: scale, y: scale)
        } else {
            visualContentView.transform = .identity
            let normalSize = appearance.textFont.pointSize
            let selectedSize = appearance.selectedTextFont.pointSize
            let fontSize = interpolate(from: normalSize, to: selectedSize, progress: p)
            let weight = p > 0.5 ? fontWeight(from: appearance.selectedTextFont) : fontWeight(from: appearance.textFont)
            titleLabel.font = .systemFont(ofSize: fontSize, weight: weight)
            titleLabel.textColor = UIColor.zwb_interpolate(from: appearance.normalTextColor, to: appearance.selectedTextColor, progress: p)
            indicatorView.alpha = p
        }

        layoutBackground(mode: appearance.selectedBackgroundMode)
        setNeedsLayout()
    }

    private func setupUI() {
        contentView.backgroundColor = .clear
        backgroundImageView.alpha = 0
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.75
        iconImageView.contentMode = .scaleAspectFit
        visualContentView.backgroundColor = .clear
        contentView.addSubview(visualContentView)
        [backgroundImageView, indicatorView, titleLabel, iconImageView, badgeImageView].forEach {
            visualContentView.addSubview($0)
        }
    }

    private func layoutBackground(mode: ZWBSegmentedMenuSelectionBackgroundMode) {
        switch mode {
        case .none:
            backgroundImageView.frame = .zero
        case .original:
            backgroundImageView.sizeToFit()
        case .fill(let insets):
            backgroundImageView.frame = contentView.bounds.inset(by: insets)
        }
    }

    private func badgeFrame(in bounds: CGRect) -> CGRect {
        let size = CGSize(width: 16, height: 16)
        let isRTL = isRightToLeftContent
        switch badgePlacement {
        case .leadingCenter:
            let x = isRTL ? bounds.width - size.width - 2 : 2
            return CGRect(x: x, y: (bounds.height - size.height) / 2, width: size.width, height: size.height)
        case .trailingTop:
            let x = isRTL ? 2 : bounds.width - size.width - 2
            return CGRect(x: x, y: 2, width: size.width, height: size.height)
        }
    }

    private func interpolate(from: CGFloat, to: CGFloat, progress: CGFloat) -> CGFloat {
        from + (to - from) * progress
    }

    private func fontWeight(from font: UIFont) -> UIFont.Weight {
        let traits = font.fontDescriptor.object(forKey: .traits) as? [UIFontDescriptor.TraitKey: Any]
        let rawWeight = traits?[.weight] as? CGFloat ?? UIFont.Weight.regular.rawValue
        return UIFont.Weight(rawValue: rawWeight)
    }

    private var isRightToLeftLayout: Bool {
        if #available(iOS 10.0, *), effectiveUserInterfaceLayoutDirection == .rightToLeft {
            return true
        }
        return UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .rightToLeft ||
        UIView.userInterfaceLayoutDirection(for: UIView.appearance().semanticContentAttribute) == .rightToLeft
    }
}

private extension UIColor {
    static func zwb_interpolate(from: UIColor, to: UIColor, progress: CGFloat) -> UIColor {
        let p = min(1, max(0, progress))
        var fr: CGFloat = 0
        var fg: CGFloat = 0
        var fb: CGFloat = 0
        var fa: CGFloat = 0
        var tr: CGFloat = 0
        var tg: CGFloat = 0
        var tb: CGFloat = 0
        var ta: CGFloat = 0
        from.getRed(&fr, green: &fg, blue: &fb, alpha: &fa)
        to.getRed(&tr, green: &tg, blue: &tb, alpha: &ta)
        return UIColor(
            red: fr + (tr - fr) * p,
            green: fg + (tg - fg) * p,
            blue: fb + (tb - fb) * p,
            alpha: fa + (ta - fa) * p
        )
    }
}
