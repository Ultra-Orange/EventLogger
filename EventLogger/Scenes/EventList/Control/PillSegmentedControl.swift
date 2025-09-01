//
//  PillSegmentedControl.swift
//  EventLogger
//
//  Created by 김우성 on 8/22/25.
//

import UIKit

/// 알약(캡슐) 모양의 슬라이딩 선택 배경을 가진 세그먼트 컨트롤 (Auto Layout 기반)
public final class PillSegmentedControl: UIControl {
    // MARK: - Public API

    public var items: [String] {
        didSet { rebuildButtons() }
    }

    public private(set) var selectedIndex: Int = 0 {
        didSet {
            if !isSettingUp {
                sendActions(for: .valueChanged)
            }
            updateSelection(animated: true)
        }
    }

    public var selectedSegmentIndex: Int {
        get { selectedIndex }
        set { setSelectedIndex(newValue, animated: false) }
    }

    public var contentInsets: NSDirectionalEdgeInsets = .init(top: 6, leading: 6, bottom: 6, trailing: 6) {
        didSet {
            stackTop?.constant = contentInsets.top
            stackLeading?.constant = contentInsets.leading
            stackTrailing?.constant = -contentInsets.trailing
            stackBottom?.constant = -contentInsets.bottom
            setNeedsLayout()
        }
    }

    public var segmentSpacing: CGFloat = 6 {
        didSet {
            stackView.spacing = segmentSpacing
            setNeedsLayout()
        }
    }

    public var capsuleBackgroundColor: UIColor = .systemBlue {
        didSet { selectionCapsuleView.backgroundColor = capsuleBackgroundColor }
    }

    public var capsuleBorderColor: UIColor = .systemBlue {
        didSet { selectionCapsuleView.layer.borderColor = capsuleBorderColor.cgColor }
    }

    public var capsuleBorderWidth: CGFloat = 0 {
        didSet { selectionCapsuleView.layer.borderWidth = capsuleBorderWidth }
    }
    
    public var capsuleShadowColor: UIColor = .white {
        didSet { selectionCapsuleView.layer.shadowColor = capsuleShadowColor.cgColor }
    }

    public var capsuleShadowOpacity: Float = 1.0 {
        didSet { selectionCapsuleView.layer.shadowOpacity = capsuleShadowOpacity }
    }

    public var capsuleShadowRadius: CGFloat = 6 {
        didSet { selectionCapsuleView.layer.shadowRadius = capsuleShadowRadius }
    }

    public var capsuleShadowOffset: CGSize = .zero {
        didSet { selectionCapsuleView.layer.shadowOffset = capsuleShadowOffset }
    }

    public var borderColor: UIColor = UIColor.systemBlue.withAlphaComponent(0.6) {
        didSet { layer.borderColor = borderColor.cgColor }
    }

    public var borderWidth: CGFloat = 1.5 {
        didSet { layer.borderWidth = borderWidth }
    }

    public var normalTextColor: UIColor = .systemBlue {
        didSet { buttons.forEach { $0.setNeedsUpdateConfiguration() } }
    }

    public var selectedTextColor: UIColor = .white {
        didSet { buttons.forEach { $0.setNeedsUpdateConfiguration() } }
    }

    public var normalFont: UIFont = .systemFont(ofSize: 15, weight: .regular) {
        didSet { buttons.forEach { $0.setNeedsUpdateConfiguration() } }
    }

    public var selectedFont: UIFont = .systemFont(ofSize: 15, weight: .semibold) {
        didSet { buttons.forEach { $0.setNeedsUpdateConfiguration() } }
    }

    // 텍스트 섀도우 속성 (CALayer 기반)
    public var normalTextShadowColor: UIColor? {
        didSet { updateAllLabelShadows() }
    }

    public var selectedTextShadowColor: UIColor? {
        didSet { updateAllLabelShadows() }
    }

    public var textShadowOpacity: Float = 0.6 {
        didSet { updateAllLabelShadows() }
    }

    public var textShadowRadius: CGFloat = 2 {
        didSet { updateAllLabelShadows() }
    }

    public var textShadowOffset: CGSize = .init(width: 1, height: 1) {
        didSet { updateAllLabelShadows() }
    }

    // MARK: - Subviews

    private let stackView = UIStackView()
    private let selectionCapsuleView = UIView()
    private var buttons: [UIButton] = []

    private var stackTop: NSLayoutConstraint?
    private var stackLeading: NSLayoutConstraint?
    private var stackTrailing: NSLayoutConstraint?
    private var stackBottom: NSLayoutConstraint?

    private var capsuleConstraints: [NSLayoutConstraint] = []

    // MARK: - State flags

    private var isSettingUp = false
    private var needsInitialAttach = false

    // MARK: - Init

    public init(items: [String], selectedIndex: Int = 0) {
        self.items = items
        self.selectedIndex = max(0, min(selectedIndex, max(0, items.count - 1)))
        super.init(frame: .zero)
        isSettingUp = true
        configureOnce()
        rebuildButtons()
        isSettingUp = false
    }

    public required init?(coder: NSCoder) {
        items = []
        super.init(coder: coder)
        isSettingUp = true
        configureOnce()
        rebuildButtons()
        isSettingUp = false
    }

    // MARK: - Configuration

    private func configureOnce() {
        backgroundColor = .clear

        layer.masksToBounds = false
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor

        selectionCapsuleView.backgroundColor = capsuleBackgroundColor
        selectionCapsuleView.layer.borderColor = capsuleBorderColor.cgColor
        selectionCapsuleView.layer.borderWidth = capsuleBorderWidth
        selectionCapsuleView.layer.shadowColor = capsuleShadowColor.cgColor
        selectionCapsuleView.layer.shadowOpacity = capsuleShadowOpacity
        selectionCapsuleView.layer.shadowRadius = capsuleShadowRadius
        selectionCapsuleView.layer.shadowOffset = capsuleShadowOffset
        selectionCapsuleView.layer.masksToBounds = false
        selectionCapsuleView.isUserInteractionEnabled = false
        selectionCapsuleView.translatesAutoresizingMaskIntoConstraints = false

        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = segmentSpacing

        addSubview(selectionCapsuleView)
        addSubview(stackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        let top = stackView.topAnchor.constraint(equalTo: topAnchor, constant: contentInsets.top)
        let leading = stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: contentInsets.leading)
        let trailing = stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -contentInsets.trailing)
        let bottom = stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -contentInsets.bottom)

        NSLayoutConstraint.activate([
            top, leading, trailing, bottom,
            heightAnchor.constraint(greaterThanOrEqualToConstant: 36),
        ])

        stackTop = top
        stackLeading = leading
        stackTrailing = trailing
        stackBottom = bottom
    }

    // MARK: - Build Buttons

    private func rebuildButtons() {
        buttons.forEach { $0.removeFromSuperview() }
        buttons.removeAll()

        for (index, title) in items.enumerated() {
            let button = UIButton(type: .system)

            var configuration = UIButton.Configuration.plain()
            configuration.contentInsets = .init(top: 6, leading: 12, bottom: 6, trailing: 12)
            configuration.background.backgroundColor = .clear

            let isSelected = (index == selectedIndex)
            configuration.attributedTitle = makeAttributedTitle(text: title, isSelected: isSelected)
            configuration.baseForegroundColor = isSelected ? selectedTextColor : normalTextColor
            button.configuration = configuration

            button.configurationUpdateHandler = { [weak self] button in
                guard let self = self,
                      let buttonIndex = self.buttons.firstIndex(of: button) else { return }

                let isSelected = (buttonIndex == self.selectedIndex)
                var updated = button.configuration ?? .plain()
                updated.attributedTitle = self.makeAttributedTitle(text: self.items[buttonIndex], isSelected: isSelected)
                updated.baseForegroundColor = isSelected ? self.selectedTextColor : self.normalTextColor
                updated.background.backgroundColor = .clear
                button.configuration = updated

                // titleLabel 섀도우 적용
                if let label = button.titleLabel {
                    self.applyTextLayerShadow(to: label, isSelected: isSelected)
                }
            }

            button.addAction(UIAction { [weak self] _ in
                self?.handleTap(on: button)
            }, for: .touchUpInside)

            buttons.append(button)
            stackView.addArrangedSubview(button)
        }

        needsInitialAttach = true
        setNeedsLayout()
        invalidateIntrinsicContentSize()
    }

    // MARK: - Selection Handling

    private func handleTap(on button: UIButton) {
        guard let index = buttons.firstIndex(of: button) else { return }
        if index != selectedIndex {
            setSelectedIndex(index, animated: true)
        }
    }

    private func attachCapsule(to button: UIView, animated: Bool) {
        NSLayoutConstraint.deactivate(capsuleConstraints)
        capsuleConstraints = [
            selectionCapsuleView.topAnchor.constraint(equalTo: button.topAnchor, constant: 2),
            selectionCapsuleView.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: -2),
            selectionCapsuleView.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 2),
            selectionCapsuleView.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -2),
        ]
        NSLayoutConstraint.activate(capsuleConstraints)

        let animations = { self.layoutIfNeeded() }
        if animated {
            UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseInOut, .allowUserInteraction], animations: animations, completion: nil)
        } else {
            animations()
        }
    }

    private func updateSelection(animated: Bool) {
        buttons.forEach { $0.setNeedsUpdateConfiguration() }
        guard buttons.indices.contains(selectedIndex) else {
            selectionCapsuleView.isHidden = true
            return
        }
        selectionCapsuleView.isHidden = false

        if bounds.width == 0 || bounds.height == 0 || window == nil {
            needsInitialAttach = true
            return
        }

        let targetButton = buttons[selectedIndex]
        attachCapsule(to: targetButton, animated: animated)
    }

    // MARK: - Layout

    override public func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = 16
        selectionCapsuleView.layer.cornerRadius = 16

        let path = UIBezierPath(roundedRect: selectionCapsuleView.bounds, cornerRadius: 16).cgPath
        selectionCapsuleView.layer.shadowPath = path

        if needsInitialAttach, buttons.indices.contains(selectedIndex) {
            needsInitialAttach = false
            attachCapsule(to: buttons[selectedIndex], animated: false)
        }
    }

    override public var intrinsicContentSize: CGSize {
        let buttonHeights = buttons.map { $0.intrinsicContentSize.height }
        let height = (buttonHeights.max() ?? 28) + contentInsets.top + contentInsets.bottom
        let totalButtonsWidth = buttons.reduce(0) { $0 + $1.intrinsicContentSize.width }
        let width = totalButtonsWidth
            + CGFloat(max(0, buttons.count - 1)) * segmentSpacing
            + contentInsets.leading + contentInsets.trailing
        return CGSize(width: max(120, width), height: max(36, height))
    }

    // MARK: - Programmatic API

    public func setSelectedIndex(_ index: Int, animated: Bool) {
        let clamped = max(0, min(index, max(0, items.count - 1)))
        guard clamped != selectedIndex else { return }
        selectedIndex = clamped
        updateSelection(animated: animated)
    }

    public func setItems(_ newItems: [String], selectedIndex: Int = 0) {
        isSettingUp = true
        items = newItems
        self.selectedIndex = max(0, min(selectedIndex, max(0, newItems.count - 1)))
        isSettingUp = false
        needsInitialAttach = true
        setNeedsLayout()
        invalidateIntrinsicContentSize()
    }

    // MARK: - Helpers

    private func makeAttributedTitle(text: String, isSelected: Bool) -> AttributedString {
        let font = isSelected ? selectedFont : normalFont
        let ns = NSMutableAttributedString(string: text, attributes: [.font: font])
        return AttributedString(ns)
    }

    private func applyTextLayerShadow(to label: UILabel, isSelected: Bool) {
        label.layer.masksToBounds = false
        label.layer.shadowColor = (isSelected ? selectedTextShadowColor?.cgColor : normalTextShadowColor?.cgColor)
        label.layer.shadowOpacity = textShadowOpacity
        label.layer.shadowRadius = textShadowRadius
        label.layer.shadowOffset = textShadowOffset
        label.layer.shouldRasterize = true
        label.layer.rasterizationScale = UIScreen.main.scale
    }

    private func updateAllLabelShadows() {
        for (i, button) in buttons.enumerated() {
            if let label = button.titleLabel {
                applyTextLayerShadow(to: label, isSelected: i == selectedIndex)
            }
        }
    }
}
