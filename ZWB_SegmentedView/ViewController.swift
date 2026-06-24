//
//  ViewController.swift
//  ZWB_SegmentedView
//
//  Created by hule on 2026/6/24.
//

import UIKit

final class ViewController: UIViewController {
    private let titleLabel = UILabel()
    private let languageButton = UIButton(type: .system)
    private let tableView = UITableView(frame: .zero, style: .plain)

    private let demos: [SegmentedStyleDemo] = [
        .presetGift,
        .textAdaptive,
        .alignment,
        .discoverMixed,
        .customCell
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DemoColor.background
        setupHeader()
        setupLanguageButton()
        setupTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let safe = view.safeAreaInsets
        let width = view.bounds.width
        let buttonWidth: CGFloat = 92
        let isRTL = view.effectiveUserInterfaceLayoutDirection == .rightToLeft
        languageButton.frame = CGRect(
            x: isRTL ? 20 : width - buttonWidth - 20,
            y: safe.top + 18,
            width: buttonWidth,
            height: 34
        )
        titleLabel.frame = CGRect(
            x: isRTL ? languageButton.frame.maxX + 12 : 20,
            y: safe.top + 18,
            width: width - buttonWidth - 52,
            height: 36
        )
        titleLabel.textAlignment = isRTL ? .right : .left
        tableView.frame = CGRect(x: 0, y: titleLabel.frame.maxY + 18, width: width, height: view.bounds.height - titleLabel.frame.maxY - 18)
    }

    private func setupHeader() {
        titleLabel.text = "ZWB 分段菜单示例"
        titleLabel.textColor = DemoColor.primaryText
        titleLabel.font = .boldSystemFont(ofSize: 26)
        titleLabel.textAlignment = view.effectiveUserInterfaceLayoutDirection == .rightToLeft ? .right : .left
        view.addSubview(titleLabel)
    }

    private func setupLanguageButton() {
        languageButton.setTitle(DemoLanguage.isArabicMode ? "中文模式" : "阿语模式", for: .normal)
        languageButton.setTitleColor(.white, for: .normal)
        languageButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        languageButton.backgroundColor = UIColor(red: 0.98, green: 0.23, blue: 0.42, alpha: 1)
        languageButton.layer.cornerRadius = 17
        languageButton.layer.masksToBounds = true
        languageButton.addTarget(self, action: #selector(toggleLanguageMode), for: .touchUpInside)
        view.addSubview(languageButton)
    }

    @objc private func toggleLanguageMode() {
        DemoLanguage.isArabicMode.toggle()
        DemoLanguage.applyCurrentLayoutDirection()

        guard let window = view.window else { return }
        let rootController = ViewController()
        let navigationController = UINavigationController(rootViewController: rootController)
        navigationController.navigationBar.tintColor = UIColor(red: 0.98, green: 0.23, blue: 0.42, alpha: 1)
        navigationController.setNavigationBarHidden(true, animated: false)
        window.rootViewController = navigationController
        window.semanticContentAttribute = DemoLanguage.isArabicMode ? .forceRightToLeft : .forceLeftToRight
        UIView.transition(with: window, duration: 0.25, options: .transitionCrossDissolve, animations: nil)
    }

    private func setupTableView() {
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 4, left: 0, bottom: 24, right: 0)
        tableView.rowHeight = 86
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(DemoStyleCell.self, forCellReuseIdentifier: DemoStyleCell.reuseIdentifier)
        view.addSubview(tableView)
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        demos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DemoStyleCell.reuseIdentifier, for: indexPath) as! DemoStyleCell
        cell.configure(with: demos[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // 每种样式使用独立 Controller，避免示例代码都混在一个 switch 里影响阅读。
        let controller = demos[indexPath.row].makeController()
        if let navigationController {
            navigationController.pushViewController(controller, animated: true)
        } else {
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }
    }
}

private final class DemoStyleCell: UITableViewCell {
    static let reuseIdentifier = "DemoStyleCell"

    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let detailLabel = UILabel()
    private let arrowLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.frame = bounds.inset(by: UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16))
        let isRTL = effectiveUserInterfaceLayoutDirection == .rightToLeft
        titleLabel.textAlignment = isRTL ? .right : .left
        detailLabel.textAlignment = isRTL ? .right : .left
        arrowLabel.text = isRTL ? "‹" : "›"
        arrowLabel.frame = CGRect(x: isRTL ? 12 : containerView.bounds.width - 34, y: 0, width: 22, height: containerView.bounds.height)
        let textX: CGFloat = isRTL ? 46 : 16
        titleLabel.frame = CGRect(x: textX, y: 13, width: containerView.bounds.width - 64, height: 24)
        detailLabel.frame = CGRect(x: textX, y: titleLabel.frame.maxY + 5, width: containerView.bounds.width - 64, height: 20)
    }

    func configure(with demo: SegmentedStyleDemo) {
        titleLabel.text = demo.title
        detailLabel.text = demo.detail
    }

    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none

        containerView.backgroundColor = DemoColor.card
        containerView.layer.cornerRadius = 8
        containerView.layer.masksToBounds = true
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = DemoColor.stroke.cgColor

        titleLabel.textColor = DemoColor.primaryText
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textAlignment = effectiveUserInterfaceLayoutDirection == .rightToLeft ? .right : .left
        detailLabel.textColor = DemoColor.secondaryText
        detailLabel.font = .systemFont(ofSize: 13)
        detailLabel.textAlignment = effectiveUserInterfaceLayoutDirection == .rightToLeft ? .right : .left
        arrowLabel.text = effectiveUserInterfaceLayoutDirection == .rightToLeft ? "‹" : "›"
        arrowLabel.textColor = DemoColor.secondaryText
        arrowLabel.font = .systemFont(ofSize: 30, weight: .regular)
        arrowLabel.textAlignment = .center

        contentView.addSubview(containerView)
        [titleLabel, detailLabel, arrowLabel].forEach { containerView.addSubview($0) }
    }
}

enum DemoColor {
    static let background = UIColor(red: 0.93, green: 0.95, blue: 0.98, alpha: 1)
    static let card = UIColor.white
    static let panel = UIColor(red: 0.16, green: 0.18, blue: 0.28, alpha: 1)
    static let primaryText = UIColor(red: 0.09, green: 0.10, blue: 0.16, alpha: 1)
    static let secondaryText = UIColor(red: 0.42, green: 0.45, blue: 0.55, alpha: 1)
    static let stroke = UIColor(red: 0.82, green: 0.85, blue: 0.91, alpha: 1)
}

enum DemoLanguage {
    private static let arabicModeKey = "ZWB_SegmentedView_Demo_ArabicMode"

    static var isArabicMode: Bool {
        get { UserDefaults.standard.bool(forKey: arabicModeKey) }
        set { UserDefaults.standard.set(newValue, forKey: arabicModeKey) }
    }

    static func applyCurrentLayoutDirection() {
        UIView.appearance().semanticContentAttribute = isArabicMode ? .forceRightToLeft : .forceLeftToRight
    }
}
