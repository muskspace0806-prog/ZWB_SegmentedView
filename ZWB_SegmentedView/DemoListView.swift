//
//  DemoListView.swift
//  ZWB_SegmentedView
//

import UIKit

final class DemoListView: UIView, JXSegmentedListContainerViewListDelegate {
    private let title: String
    private let index: Int
    private let titleLabel = UILabel()
    private let detailLabel = UILabel()

    init(title: String, index: Int) {
        self.title = title
        self.index = index
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func listView() -> UIView {
        self
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = CGRect(x: 20, y: 38, width: bounds.width - 40, height: 34)
        detailLabel.frame = CGRect(x: 24, y: titleLabel.frame.maxY + 10, width: bounds.width - 48, height: 52)
        let isRTL = effectiveUserInterfaceLayoutDirection == .rightToLeft
        titleLabel.textAlignment = isRTL ? .right : .left
        detailLabel.textAlignment = isRTL ? .right : .left
    }

    private func setupUI() {
        backgroundColor = UIColor(red: 0.97, green: 0.98, blue: 1.00, alpha: 1)

        titleLabel.text = title
        titleLabel.textColor = DemoColor.primaryText
        titleLabel.font = .boldSystemFont(ofSize: 28)
        titleLabel.textAlignment = effectiveUserInterfaceLayoutDirection == .rightToLeft ? .right : .left

        detailLabel.text = "第 \(index + 1) 个页面，由 JXSegmentedListContainerView 懒加载并跟随菜单切换。"
        detailLabel.textColor = DemoColor.secondaryText
        detailLabel.font = .systemFont(ofSize: 14)
        detailLabel.textAlignment = effectiveUserInterfaceLayoutDirection == .rightToLeft ? .right : .left
        detailLabel.numberOfLines = 0

        addSubview(titleLabel)
        addSubview(detailLabel)
    }
}
