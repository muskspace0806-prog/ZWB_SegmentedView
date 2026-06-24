//
//  ZWBHiddenSegmentedDataSource.swift
//  ZWB_SegmentedView
//

import UIKit

open class ZWBHiddenSegmentedDataSource: JXSegmentedTitleDataSource {
    public init(count: Int) {
        super.init()
        titles = Array(repeating: "", count: count)
        itemWidth = 1
        itemSpacing = 0
        isItemSpacingAverageEnabled = false
    }

    public func update(count: Int) {
        titles = Array(repeating: "", count: count)
    }
}

