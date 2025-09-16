//
//  PillSegmentedControl.swift
//  EventLogger
//
//  Created by 김우성 on 8/22/25.
//

import RxCocoa
import RxSwift
import SnapKit
import Then
import UIKit

public final class PillSegmentedControl: UIControl {
    // MARK: Public API
    public var items: [String] { didSet { rebuildButtons() } }

    public var selectedIndex: Int {
        get { _selectedIndex }
        set { setSelectedIndex(newValue, animated: false) }
    }

    // MARK: Theme/Subviews/State (동일)
    private enum Theme {
        static var capsuleBackground: UIColor { .appBackground }
        static var capsuleBorder: UIColor { .primary500 }
        static var textNormal: UIColor { .neutral50 }
        static var textSelected: UIColor { .primary200 }
        static var shadowColor: UIColor { .primary500 }
        static var fontNormal: UIFont { .font17Regular }
        static var fontSelected: UIFont { .font17Semibold }
        static let controlCorner: CGFloat = 16
        static let capsuleBorderWidth: CGFloat = 1
        static let contentInsets = NSDirectionalEdgeInsets(top: 3, leading: 3, bottom: 3, trailing: 3)
        static let segmentSpacing: CGFloat = 6
        static let buttonContentInsets = NSDirectionalEdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)
        static let minHeight: CGFloat = 50
        static let attachInset: CGFloat = 2
        static let textShadowRadius: CGFloat = 7
        static let textShadowOffset: CGSize = .zero
    }

    private let stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .fill
        $0.distribution = .fillEqually
        $0.spacing = Theme.segmentSpacing
    }

    private let selectionCapsuleView = UIView().then {
        $0.isUserInteractionEnabled = false
        $0.backgroundColor = Theme.capsuleBackground
        $0.layer.borderColor = Theme.capsuleBorder.cgColor
        $0.layer.borderWidth = Theme.capsuleBorderWidth
        $0.layer.shadowColor = Theme.shadowColor.cgColor
        $0.layer.shadowOpacity = 1
        $0.layer.shadowRadius = 6
        $0.layer.shadowOffset = .zero
        $0.layer.masksToBounds = false
    }

    private var buttons: [UIButton] = []
    private var _selectedIndex: Int = 0
    private var isSettingUp = false
    private var needsInitialAttach = false

    // MARK: Init/Setup (동일)
    public init(items: [String], selectedIndex: Int = 0) {
        self.items = items
        _selectedIndex = max(0, min(selectedIndex, max(0, items.count - 1)))
        super.init(frame: .zero)
        isSettingUp = true
        configure()
        rebuildButtons()
        isSettingUp = false
    }

    public required init?(coder: NSCoder) {
        items = []
        super.init(coder: coder)
        isSettingUp = true
        configure()
        rebuildButtons()
        isSettingUp = false
    }

    private func configure() {
        backgroundColor = .clear
        layer.masksToBounds = false
        addSubview(selectionCapsuleView)
        addSubview(stackView)
        stackView.snp.makeConstraints { $0.edges.equalTo(Theme.contentInsets) }
        snp.makeConstraints { $0.height.greaterThanOrEqualTo(Theme.minHeight) }
    }

    private func rebuildButtons() {
        buttons.forEach { $0.removeFromSuperview() }
        buttons.removeAll()

        for (index, title) in items.enumerated() {
            let button = UIButton(type: .system).then { btn in
                var cfg = UIButton.Configuration.plain()
                cfg.contentInsets = Theme.buttonContentInsets
                cfg.background.backgroundColor = .clear
                let isSel = (index == _selectedIndex)
                cfg.attributedTitle = attributed(title: title, selected: isSel)
                cfg.baseForegroundColor = isSel ? Theme.textSelected : Theme.textNormal
                btn.configuration = cfg

                btn.configurationUpdateHandler = { [weak self] b in
                    guard let self = self, let idx = self.buttons.firstIndex(of: b) else { return }
                    let selected = (idx == self._selectedIndex)
                    var updated = b.configuration ?? .plain()
                    updated.attributedTitle = self.attributed(title: self.items[idx], selected: selected)
                    updated.baseForegroundColor = selected ? Theme.textSelected : Theme.textNormal
                    updated.background.backgroundColor = .clear
                    b.configuration = updated
                    if let label = b.titleLabel { self.applyTextShadow(to: label, selected: selected) }
                }

                btn.addAction(UIAction { [weak self] _ in
                    guard let self = self else { return }
                    if let idx = self.buttons.firstIndex(of: btn), idx != self._selectedIndex {
                        self.setSelectedIndex(idx, animated: true)
                        self.sendActions(for: .valueChanged)
                    }
                }, for: .touchUpInside)
            }
            buttons.append(button)
            stackView.addArrangedSubview(button)
        }

        needsInitialAttach = true
        setNeedsLayout()
        invalidateIntrinsicContentSize()
    }

    public func setSelectedIndex(_ index: Int, animated: Bool) {
        let clamped = max(0, min(index, max(0, items.count - 1)))
        guard clamped != _selectedIndex else { return }
        _selectedIndex = clamped
        updateSelection(animated: animated)
    }

    public func setItems(_ newItems: [String], selectedIndex: Int = 0) {
        isSettingUp = true
        items = newItems
        _selectedIndex = max(0, min(selectedIndex, max(0, newItems.count - 1)))
        isSettingUp = false
        needsInitialAttach = true
        setNeedsLayout()
        invalidateIntrinsicContentSize()
    }

    private func updateSelection(animated: Bool) {
        buttons.forEach { $0.setNeedsUpdateConfiguration() }
        guard buttons.indices.contains(_selectedIndex) else {
            selectionCapsuleView.isHidden = true
            return
        }
        selectionCapsuleView.isHidden = false

        if bounds.width == 0 || bounds.height == 0 || window == nil {
            needsInitialAttach = true
            return
        }
        attachCapsule(to: buttons[_selectedIndex], animated: animated)
    }

    private func attachCapsule(to target: UIView, animated: Bool) {
        selectionCapsuleView.snp.remakeConstraints { $0.edges.equalTo(target).inset(Theme.attachInset) }
        let animations = { self.layoutIfNeeded() }
        animated ? UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseInOut, .allowUserInteraction], animations: animations) : animations()
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = Theme.controlCorner
        selectionCapsuleView.layer.cornerRadius = Theme.controlCorner
        selectionCapsuleView.layer.shadowPath = UIBezierPath(
            roundedRect: selectionCapsuleView.bounds,
            cornerRadius: Theme.controlCorner
        ).cgPath

        if needsInitialAttach, buttons.indices.contains(_selectedIndex) {
            needsInitialAttach = false
            attachCapsule(to: buttons[_selectedIndex], animated: false)
        }
    }

    // Helpers
    private func attributed(title: String, selected: Bool) -> AttributedString {
        let font = selected ? Theme.fontSelected : Theme.fontNormal
        let ns = NSMutableAttributedString(string: title, attributes: [.font: font])
        return AttributedString(ns)
    }

    private func applyTextShadow(to label: UILabel, selected: Bool) {
        label.layer.masksToBounds = false
        label.shadowColor = selected ? Theme.shadowColor : nil
        label.layer.shadowRadius = Theme.textShadowRadius
        label.shadowOffset = Theme.textShadowOffset
    }
}

// MARK: - Rx
public extension Reactive where Base: PillSegmentedControl {
    /// 유저 상호작용(.valueChanged)만 방출
    var indexChangedByUser: ControlEvent<Int> {
        ControlEvent(events: controlEvent(.valueChanged).map { base.selectedIndex })
    }

    /// 양방향 바인딩용 (values는 valueChanged만, sink는 programmatic set)
    var selectedSegmentIndex: ControlProperty<Int> {
        let values = controlEvent(.valueChanged).map { base.selectedIndex }
        let sink = Binder(base) { ctrl, newIndex in ctrl.selectedIndex = newIndex }.asObserver()
        return ControlProperty(values: values, valueSink: sink)
    }
}
