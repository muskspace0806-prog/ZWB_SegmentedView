//
//  ZWBSegmentedMenuBinding.swift
//  ZWB_SegmentedView
//

import UIKit
import ObjectiveC

public final class ZWBSegmentedMenuBinding {
    public let dataSource: ZWBHiddenSegmentedDataSource
    public let coordinator: ZWBSegmentedMenuCoordinator

    init(dataSource: ZWBHiddenSegmentedDataSource, coordinator: ZWBSegmentedMenuCoordinator) {
        self.dataSource = dataSource
        self.coordinator = coordinator
    }
}

private var zwbMenuBindingKey: UInt8 = 0

public extension JXSegmentedView {
    @discardableResult
    func zwb_bindCustomMenu(
        _ menuView: ZWBSegmentedMenuView,
        items: [ZWBMenuItem],
        listContainer: JXSegmentedViewListContainer? = nil,
        selectedIndex: Int = 0,
        onSelectedIndexChanged: ((Int) -> Void)? = nil
    ) -> ZWBSegmentedMenuBinding {
        let dataSource = ZWBHiddenSegmentedDataSource(count: items.count)
        let safeSelectedIndex = items.isEmpty ? 0 : max(0, min(selectedIndex, items.count - 1))

        zwb_prepareAsInvisiblePageDriver()
        defaultSelectedIndex = safeSelectedIndex
        self.dataSource = dataSource
        if let listContainer {
            self.listContainer = listContainer
        }
        menuView.reload(items: items, selectedIndex: safeSelectedIndex)

        let coordinator = ZWBSegmentedMenuCoordinator(segmentedView: self, menuView: menuView)
        coordinator.onSelectedIndexChanged = onSelectedIndexChanged

        let binding = ZWBSegmentedMenuBinding(dataSource: dataSource, coordinator: coordinator)
        objc_setAssociatedObject(self, &zwbMenuBindingKey, binding, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return binding
    }
}
