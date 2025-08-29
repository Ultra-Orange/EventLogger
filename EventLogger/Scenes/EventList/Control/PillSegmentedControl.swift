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

    /// 표시할 항목 텍스트 배열
    public var items: [String] {
        didSet { rebuildButtons() }
    }

    /// 현재 선택된 인덱스
    public private(set) var selectedIndex: Int = 0 {
        didSet {
            if !isSettingUp {
                sendActions(for: .valueChanged)
            }
            updateSelection(animated: true)
        }
    }

    /// 외부에서 UISegmentedControl처럼 접근할 수 있도록 유지 (Rx 확장에서 사용)
    public var selectedSegmentIndex: Int {
        get { selectedIndex }
        set { setSelectedIndex(newValue, animated: false) }
    }

    /// 바깥 알약 컨테이너 안쪽 여백
    public var contentInsets: NSDirectionalEdgeInsets = .init(top: 6, leading: 6, bottom: 6, trailing: 6) {
        didSet {
            stackTop?.constant = contentInsets.top
            stackLeading?.constant = contentInsets.leading
            stackTrailing?.constant = -contentInsets.trailing
            stackBottom?.constant = -contentInsets.bottom
            setNeedsLayout()
        }
    }

    /// 세그먼트 간 간격
    public var segmentSpacing: CGFloat = 6 {
        didSet {
            stackView.spacing = segmentSpacing
            setNeedsLayout()
        }
    }

    /// 선택 캡슐 배경색
    public var capsuleBackgroundColor: UIColor = .systemBlue {
        didSet { selectionCapsuleView.backgroundColor = capsuleBackgroundColor }
    }

    /// 선택 캡슐 외곽선 색
    public var capsuleBorderColor: UIColor = .systemBlue {
        didSet { selectionCapsuleView.layer.borderColor = capsuleBorderColor.cgColor }
    }

    /// 선택 캡슐 외곽선 두께
    public var capsuleBorderWidth: CGFloat = 0 {
        didSet { selectionCapsuleView.layer.borderWidth = capsuleBorderWidth }
    }
    
    /// 선택 캡슐 섀도우 속성
    public var capsuleShadowColor: UIColor = UIColor(red: 0.961, green: 0.397, blue: 0.019, alpha: 1) {
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

    /// 외곽선 색
    public var borderColor: UIColor = UIColor.systemBlue.withAlphaComponent(0.6) {
        didSet { layer.borderColor = borderColor.cgColor }
    }

    /// 외곽선 두께
    public var borderWidth: CGFloat = 1.5 {
        didSet { layer.borderWidth = borderWidth }
    }

    /// 비선택 텍스트 색
    public var normalTextColor: UIColor = .systemBlue {
        didSet { buttons.forEach { $0.setNeedsUpdateConfiguration() } }
    }

    /// 선택 텍스트 색
    public var selectedTextColor: UIColor = .white {
        didSet { buttons.forEach { $0.setNeedsUpdateConfiguration() } }
    }

    /// 폰트
    public var font: UIFont = .systemFont(ofSize: 15, weight: .medium) {
        didSet { buttons.forEach { $0.setNeedsUpdateConfiguration() } }
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

        // 외곽 알약 스타일
        layer.masksToBounds = false
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
        
        // 선택 캡슐
        selectionCapsuleView.backgroundColor = capsuleBackgroundColor
        selectionCapsuleView.layer.borderColor = capsuleBorderColor.cgColor
        selectionCapsuleView.layer.borderWidth = capsuleBorderWidth
        // 섀도우 기본값
        selectionCapsuleView.layer.shadowColor = capsuleShadowColor.cgColor
        selectionCapsuleView.layer.shadowOpacity = capsuleShadowOpacity
        selectionCapsuleView.layer.shadowRadius = capsuleShadowRadius
        selectionCapsuleView.layer.shadowOffset = capsuleShadowOffset
        selectionCapsuleView.layer.masksToBounds = false
        selectionCapsuleView.isUserInteractionEnabled = false
        selectionCapsuleView.translatesAutoresizingMaskIntoConstraints = false

        // 스택
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
            configuration.attributedTitle = AttributedString(title, attributes: .init([.font: font]))
            configuration.baseForegroundColor = (index == selectedIndex) ? selectedTextColor : normalTextColor
            button.configuration = configuration

            button.configurationUpdateHandler = { [weak self] button in
                guard let self = self,
                      let buttonIndex = self.buttons.firstIndex(of: button) else { return }
                var updated = button.configuration ?? .plain()
                updated.attributedTitle = AttributedString(self.items[buttonIndex], attributes: .init([.font: self.font]))
                updated.baseForegroundColor = (buttonIndex == self.selectedIndex) ? self.selectedTextColor : self.normalTextColor
                updated.background.backgroundColor = .clear
                button.configuration = updated
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

    public override func layoutSubviews() {
        super.layoutSubviews()

        // 원형률은 고정 16으로 통일 (상단/하단에서 중복 세팅 제거)
        layer.cornerRadius = 16
        selectionCapsuleView.layer.cornerRadius = 16

        // shadowPath를 현재 캡슐 프레임에 맞게 갱신
        let path = UIBezierPath(roundedRect: selectionCapsuleView.bounds, cornerRadius: 16).cgPath
        selectionCapsuleView.layer.shadowPath = path

        if needsInitialAttach, buttons.indices.contains(selectedIndex) {
            needsInitialAttach = false
            attachCapsule(to: buttons[selectedIndex], animated: false)
        }
    }

    public override var intrinsicContentSize: CGSize {
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

    private func animateStackFade() {
        stackView.alpha = 0
        UIView.animate(withDuration: 0.18) {
            self.stackView.alpha = 1
        }
    }
}
