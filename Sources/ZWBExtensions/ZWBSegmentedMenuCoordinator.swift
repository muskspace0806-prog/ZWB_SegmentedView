//
//  ZWBSegmentedMenuCoordinator.swift
//  ZWB_SegmentedView
//

import UIKit

public final class ZWBSegmentedMenuCoordinator: NSObject {
    public weak var forwardedDelegate: JXSegmentedViewDelegate?
    public var onSelectedIndexChanged: ((Int) -> Void)?

    private weak var segmentedView: JXSegmentedView?
    private weak var menuView: ZWBSegmentedMenuView?
    private var isSelecting = false

    public init(segmentedView: JXSegmentedView, menuView: ZWBSegmentedMenuView) {
        self.segmentedView = segmentedView
        self.menuView = menuView
        super.init()

        segmentedView.delegate = self
        menuView.onSelect = { [weak self] index in
            self?.select(index: index, animated: true)
        }
    }

    public func select(index: Int, animated: Bool = true) {
        guard !isSelecting else { return }
        isSelecting = true
        menuView?.select(index: index, animated: animated)
        segmentedView?.selectItemAt(index: index)
        isSelecting = false
    }
}

extension ZWBSegmentedMenuCoordinator: JXSegmentedViewDelegate {
    public func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        menuView?.select(index: index, animated: true)
        onSelectedIndexChanged?(index)
        forwardedDelegate?.segmentedView(segmentedView, didSelectedItemAt: index)
    }

    public func segmentedView(_ segmentedView: JXSegmentedView, didClickSelectedItemAt index: Int) {
        forwardedDelegate?.segmentedView(segmentedView, didClickSelectedItemAt: index)
    }

    public func segmentedView(_ segmentedView: JXSegmentedView, didScrollSelectedItemAt index: Int) {
        forwardedDelegate?.segmentedView(segmentedView, didScrollSelectedItemAt: index)
    }

    public func segmentedView(_ segmentedView: JXSegmentedView, scrollingFrom leftIndex: Int, to rightIndex: Int, percent: CGFloat) {
        menuView?.updateScrollProgress(leftIndex: leftIndex, rightIndex: rightIndex, percent: percent)
        forwardedDelegate?.segmentedView(segmentedView, scrollingFrom: leftIndex, to: rightIndex, percent: percent)
    }

    public func segmentedView(_ segmentedView: JXSegmentedView, canClickItemAt index: Int) -> Bool {
        forwardedDelegate?.segmentedView(segmentedView, canClickItemAt: index) ?? true
    }
}

public extension JXSegmentedView {
    func zwb_prepareAsInvisiblePageDriver() {
        backgroundColor = .clear
        isHidden = true
        collectionView?.isScrollEnabled = false
        contentEdgeInsetLeft = 0
        contentEdgeInsetRight = 0
        isContentScrollViewClickTransitionAnimationEnabled = true
    }
}
