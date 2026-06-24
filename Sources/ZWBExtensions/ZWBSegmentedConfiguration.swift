//
//  ZWBSegmentedConfiguration.swift
//  ZWB_SegmentedView
//

import UIKit
import ObjectiveC

/// ZWB 对 JXSegmentedView 高频属性组合的语义化封装。
///
/// 原 JX 的所有属性仍然可以直接使用；本配置只是把常见组合收敛成业务能读懂的模式。
/// 如果业务在调用 `zwb_apply` 之后继续手动修改 `itemSpacing`、`indicatorWidth` 等属性，
/// 手动修改会按 JX 原逻辑生效。
public struct ZWBSegmentedConfiguration {
    /// cell 宽度策略。
    public var widthMode: ZWBSegmentedWidthMode
    /// cell 之间的间距策略。
    public var spacingMode: ZWBSegmentedSpacingMode
    /// 内容在 segmentedView 内的整体对齐策略。
    public var alignment: ZWBSegmentedAlignment
    /// 底部 indicator 策略。
    public var indicatorMode: ZWBSegmentedIndicatorMode
    /// 标题颜色和字体策略。只对 `JXSegmentedTitleDataSource` 生效。
    public var titleStyle: ZWBSegmentedTitleStyle?

    public init(
        widthMode: ZWBSegmentedWidthMode = .content(padding: 16, minWidth: 0),
        spacingMode: ZWBSegmentedSpacingMode = .fixed(0),
        alignment: ZWBSegmentedAlignment = .leading(inset: 0),
        indicatorMode: ZWBSegmentedIndicatorMode = .content(extra: 0, height: 2, color: .red),
        titleStyle: ZWBSegmentedTitleStyle? = nil
    ) {
        self.widthMode = widthMode
        self.spacingMode = spacingMode
        self.alignment = alignment
        self.indicatorMode = indicatorMode
        self.titleStyle = titleStyle
    }
}

public extension ZWBSegmentedConfiguration {
    /// 礼物面板这类顶部横向菜单：文字自适应、靠前排列、固定间距、line 跟随文字宽度。
    static func giftMenu(
        normalColor: UIColor,
        selectedColor: UIColor,
        indicatorColor: UIColor
    ) -> ZWBSegmentedConfiguration {
        ZWBSegmentedConfiguration(
            widthMode: .content(padding: 16, minWidth: 70),
            spacingMode: .fixed(0),
            alignment: .leading(inset: 14),
            indicatorMode: .content(extra: 0, height: 2, color: indicatorColor),
            titleStyle: ZWBSegmentedTitleStyle(
                normalColor: normalColor,
                selectedColor: selectedColor,
                normalFont: .systemFont(ofSize: 17),
                selectedFont: .systemFont(ofSize: 17),
                colorGradientEnabled: true
            )
        )
    }

    /// 少量 tab 平分展示，常用于固定宽度弹窗或二三级 tab。
    static func equalTabs(indicatorColor: UIColor) -> ZWBSegmentedConfiguration {
        ZWBSegmentedConfiguration(
            widthMode: .equal,
            spacingMode: .none,
            alignment: .fill,
            indicatorMode: .item(extra: 0, height: 2, color: indicatorColor)
        )
    }

    /// 文字自适应并整体居中，常用于 tab 数量少且不希望铺满的页面。
    static func centeredContent(indicatorColor: UIColor) -> ZWBSegmentedConfiguration {
        ZWBSegmentedConfiguration(
            widthMode: .content(padding: 20, minWidth: 0),
            spacingMode: .fixed(18),
            alignment: .center(inset: 12),
            indicatorMode: .content(extra: 0, height: 2, color: indicatorColor)
        )
    }
}

public enum ZWBSegmentedWidthMode {
    /// 跟随内容宽度。`padding` 是 cell 在内容宽度之外额外增加的总宽度；`minWidth` 是 cell 最小宽度。
    case content(padding: CGFloat, minWidth: CGFloat)
    /// 固定 cell 宽度。
    case fixed(CGFloat)
    /// 按 segmentedView 当前宽度平均分配。布局阶段会自动按 bounds 重新计算。
    case equal
}

public enum ZWBSegmentedSpacingMode {
    /// 无间距。
    case none
    /// 固定 cell 间距。
    case fixed(CGFloat)
    /// 当内容宽度小于容器宽度时，让 JX 自动均分剩余间距。
    case average(minimum: CGFloat)
}

public enum ZWBSegmentedAlignment {
    /// 靠前。LTR 下靠左，RTL 场景建议仍用业务语义理解为 leading。
    case leading(inset: CGFloat)
    /// 居中。内容宽度小于容器时左右 inset 自动变大。
    case center(inset: CGFloat)
    /// 靠后。内容宽度小于容器时左侧或前侧 inset 自动变大。
    case trailing(inset: CGFloat)
    /// 铺满容器，通常配合 `.equal` 或 `.average` 使用。
    case fill
}

public enum ZWBSegmentedIndicatorMode {
    /// 不显示 indicator。
    case hidden
    /// 固定宽度 indicator。
    case fixed(width: CGFloat, height: CGFloat, color: UIColor)
    /// indicator 跟随文字内容宽度。
    case content(extra: CGFloat, height: CGFloat, color: UIColor)
    /// indicator 跟随整个 cell 宽度。
    case item(extra: CGFloat, height: CGFloat, color: UIColor)
}

public struct ZWBSegmentedTitleStyle {
    public var normalColor: UIColor
    public var selectedColor: UIColor
    public var normalFont: UIFont
    public var selectedFont: UIFont?
    public var colorGradientEnabled: Bool

    public init(
        normalColor: UIColor,
        selectedColor: UIColor,
        normalFont: UIFont,
        selectedFont: UIFont? = nil,
        colorGradientEnabled: Bool = true
    ) {
        self.normalColor = normalColor
        self.selectedColor = selectedColor
        self.normalFont = normalFont
        self.selectedFont = selectedFont
        self.colorGradientEnabled = colorGradientEnabled
    }
}

private var zwbStoredConfigurationKey: UInt8 = 0

private final class ZWBSegmentedStoredConfiguration {
    weak var dataSource: JXSegmentedBaseDataSource?
    var configuration: ZWBSegmentedConfiguration
    var lastAppliedWidth: CGFloat = -1

    init(dataSource: JXSegmentedBaseDataSource, configuration: ZWBSegmentedConfiguration) {
        self.dataSource = dataSource
        self.configuration = configuration
    }
}

public extension JXSegmentedView {
    /// 应用 ZWB 语义化配置。
    ///
    /// - Important: 该方法不会替换 JX 原有能力。你仍然可以继续直接设置
    ///   `dataSource.itemSpacing`、`segmentedView.indicators` 等属性。
    /// - Parameters:
    ///   - configuration: 语义化配置。
    ///   - dataSource: 原 JX 数据源。当前会对 `JXSegmentedBaseDataSource` 及其子类生效。
    ///   - reloadData: 是否立即刷新。默认 `true`。
    func zwb_apply(
        _ configuration: ZWBSegmentedConfiguration,
        dataSource: JXSegmentedBaseDataSource,
        reloadData: Bool = true
    ) {
        let stored = ZWBSegmentedStoredConfiguration(dataSource: dataSource, configuration: configuration)
        objc_setAssociatedObject(self, &zwbStoredConfigurationKey, stored, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        zwb_applyStaticConfiguration(configuration, dataSource: dataSource)
        zwb_applyLayoutConfigurationIfNeeded(force: true)
        self.dataSource = dataSource

        if reloadData {
            self.reloadData()
        }
    }
}

extension JXSegmentedView {
    /// JXSegmentedView.layoutSubviews 中会调用该方法，让 `.center/.trailing/.equal` 在拿到真实 bounds 后自动补算。
    func zwb_applyLayoutConfigurationIfNeeded(force: Bool = false) {
        guard let stored = objc_getAssociatedObject(self, &zwbStoredConfigurationKey) as? ZWBSegmentedStoredConfiguration,
              let dataSource = stored.dataSource else {
            return
        }

        let width = bounds.width
        guard width > 0 else { return }
        guard force || abs(width - stored.lastAppliedWidth) > 0.5 else { return }

        stored.lastAppliedWidth = width
        zwb_applyWidthMode(stored.configuration.widthMode, dataSource: dataSource)
        zwb_applyAlignment(stored.configuration.alignment, dataSource: dataSource)
    }

    private func zwb_applyStaticConfiguration(
        _ configuration: ZWBSegmentedConfiguration,
        dataSource: JXSegmentedBaseDataSource
    ) {
        zwb_applyWidthMode(configuration.widthMode, dataSource: dataSource)
        zwb_applySpacingMode(configuration.spacingMode, dataSource: dataSource)
        zwb_applyTitleStyle(configuration.titleStyle, dataSource: dataSource)
        zwb_applyIndicatorMode(configuration.indicatorMode)
    }

    private func zwb_applyWidthMode(_ mode: ZWBSegmentedWidthMode, dataSource: JXSegmentedBaseDataSource) {
        switch mode {
        case let .content(padding, minWidth):
            dataSource.itemWidth = JXSegmentedViewAutomaticDimension
            dataSource.itemWidthIncrement = padding
            if let titleDataSource = dataSource as? JXSegmentedTitleDataSource {
                let originalClosure = titleDataSource.widthForTitleClosure
                titleDataSource.widthForTitleClosure = { [weak titleDataSource] title in
                    let rawWidth: CGFloat
                    if let originalClosure {
                        rawWidth = originalClosure(title)
                    } else {
                        let font = titleDataSource?.titleNormalFont ?? .systemFont(ofSize: 15)
                        rawWidth = ceil((title as NSString).boundingRect(
                            with: CGSize(width: CGFloat.infinity, height: CGFloat.infinity),
                            options: [.usesFontLeading, .usesLineFragmentOrigin],
                            attributes: [.font: font],
                            context: nil
                        ).width)
                    }
                    return max(rawWidth, minWidth - padding)
                }
            }
        case let .fixed(width):
            dataSource.itemWidth = width
            dataSource.itemWidthIncrement = 0
        case .equal:
            let count = max(dataSource.preferredItemCount(), 1)
            dataSource.itemWidth = bounds.width > 0 ? floor(bounds.width / CGFloat(count)) : JXSegmentedViewAutomaticDimension
            dataSource.itemWidthIncrement = 0
        }
    }

    private func zwb_applySpacingMode(_ mode: ZWBSegmentedSpacingMode, dataSource: JXSegmentedBaseDataSource) {
        switch mode {
        case .none:
            dataSource.itemSpacing = 0
            dataSource.isItemSpacingAverageEnabled = false
        case let .fixed(spacing):
            dataSource.itemSpacing = spacing
            dataSource.isItemSpacingAverageEnabled = false
        case let .average(minimum):
            dataSource.itemSpacing = minimum
            dataSource.isItemSpacingAverageEnabled = true
        }
    }

    private func zwb_applyAlignment(_ alignment: ZWBSegmentedAlignment, dataSource: JXSegmentedBaseDataSource) {
        let fallbackInset: CGFloat
        switch alignment {
        case let .leading(inset), let .center(inset), let .trailing(inset):
            fallbackInset = inset
        case .fill:
            contentEdgeInsetLeft = 0
            contentEdgeInsetRight = 0
            return
        }

        guard let contentWidth = zwb_estimatedContentWidth(dataSource: dataSource), bounds.width > 0 else {
            contentEdgeInsetLeft = fallbackInset
            contentEdgeInsetRight = fallbackInset
            return
        }

        let remaining = max(bounds.width - contentWidth, 0)
        switch alignment {
        case let .leading(inset):
            contentEdgeInsetLeft = inset
            contentEdgeInsetRight = inset
        case let .center(inset):
            let targetInset = max(inset, floor(remaining / 2))
            contentEdgeInsetLeft = targetInset
            contentEdgeInsetRight = targetInset
        case let .trailing(inset):
            contentEdgeInsetLeft = max(inset, remaining - inset)
            contentEdgeInsetRight = inset
        case .fill:
            break
        }
    }

    private func zwb_applyTitleStyle(_ style: ZWBSegmentedTitleStyle?, dataSource: JXSegmentedBaseDataSource) {
        guard let style, let titleDataSource = dataSource as? JXSegmentedTitleDataSource else { return }
        titleDataSource.titleNormalColor = style.normalColor
        titleDataSource.titleSelectedColor = style.selectedColor
        titleDataSource.titleNormalFont = style.normalFont
        titleDataSource.titleSelectedFont = style.selectedFont
        titleDataSource.isTitleColorGradientEnabled = style.colorGradientEnabled
    }

    private func zwb_applyIndicatorMode(_ mode: ZWBSegmentedIndicatorMode) {
        switch mode {
        case .hidden:
            indicators = []
        case let .fixed(width, height, color):
            indicators = [zwb_makeLineIndicator(width: width, widthIncrement: 0, height: height, color: color, sameAsContent: false)]
        case let .content(extra, height, color):
            indicators = [zwb_makeLineIndicator(width: JXSegmentedViewAutomaticDimension, widthIncrement: extra, height: height, color: color, sameAsContent: true)]
        case let .item(extra, height, color):
            indicators = [zwb_makeLineIndicator(width: JXSegmentedViewAutomaticDimension, widthIncrement: extra, height: height, color: color, sameAsContent: false)]
        }
    }

    private func zwb_makeLineIndicator(
        width: CGFloat,
        widthIncrement: CGFloat,
        height: CGFloat,
        color: UIColor,
        sameAsContent: Bool
    ) -> JXSegmentedIndicatorLineView {
        let indicator = JXSegmentedIndicatorLineView()
        indicator.indicatorWidth = width
        indicator.indicatorWidthIncrement = widthIncrement
        indicator.indicatorHeight = height
        indicator.indicatorColor = color
        indicator.isIndicatorWidthSameAsItemContent = sameAsContent
        return indicator
    }

    private func zwb_estimatedContentWidth(dataSource: JXSegmentedBaseDataSource) -> CGFloat? {
        let count = dataSource.preferredItemCount()
        guard count > 0 else { return nil }

        var itemWidthSum: CGFloat = 0
        if dataSource.itemWidth == JXSegmentedViewAutomaticDimension,
           let titleDataSource = dataSource as? JXSegmentedTitleDataSource {
            for title in titleDataSource.titles {
                let width = titleDataSource.widthForTitleClosure?(title) ?? ceil((title as NSString).boundingRect(
                    with: CGSize(width: CGFloat.infinity, height: CGFloat.infinity),
                    options: [.usesFontLeading, .usesLineFragmentOrigin],
                    attributes: [.font: titleDataSource.titleNormalFont],
                    context: nil
                ).width)
                itemWidthSum += width + dataSource.itemWidthIncrement
            }
        } else if dataSource.itemWidth != JXSegmentedViewAutomaticDimension {
            itemWidthSum = dataSource.itemWidth * CGFloat(count)
        } else {
            return nil
        }

        return itemWidthSum + dataSource.itemSpacing * CGFloat(max(count - 1, 0))
    }
}

