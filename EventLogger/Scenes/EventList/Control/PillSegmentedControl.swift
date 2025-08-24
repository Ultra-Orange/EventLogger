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
            // 초기 세팅 중에는 valueChanged 이벤트를 보내지 않음
            if !isSettingUp {
                sendActions(for: .valueChanged)
            }
            accessibilityValue = items.indices.contains(selectedIndex) ? items[selectedIndex] : nil
            updateSelection(animated: true)
        }
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
    public var capsuleBorderColor: UIColor = UIColor.systemBlue {
        didSet { selectionCapsuleView.layer.borderColor = capsuleBorderColor.cgColor }
    }
    
    /// 선택 캡슐 외곽선 두께
    public var capsuleBorderWidth: CGFloat = 0 {
        didSet { selectionCapsuleView.layer.borderWidth = capsuleBorderWidth }
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

    // MARK: - UISegmentedControl 호환 API (사용성 맞추기)

    /// UISegmentedControl과 동일한 네이밍
    public var selectedSegmentIndex: Int {
        get { selectedIndex }
        set { setSelectedIndex(newValue, animated: false) }
    }

    /// 총 세그먼트 개수
    public var numberOfSegments: Int { items.count }

    /// 세그먼트 타이틀 얻기
    public func titleForSegment(at index: Int) -> String? {
        guard items.indices.contains(index) else { return nil }
        return items[index]
    }

    /// 세그먼트 타이틀 설정
    public func setTitle(_ title: String?, forSegmentAt index: Int) {
        guard items.indices.contains(index) else { return }
        let newTitle = title ?? ""
        items[index] = newTitle
        // 버튼만 부분 업데이트
        if buttons.indices.contains(index) {
            let button = buttons[index]
            var cfg = button.configuration ?? .plain()
            cfg.attributedTitle = AttributedString(newTitle, attributes: .init([.font: font]))
            button.configuration = cfg
        } else {
            rebuildButtons()
        }
        invalidateIntrinsicContentSize()
        setNeedsLayout()
    }

    /// 세그먼트 삽입
    public func insertSegment(withTitle title: String?, at index: Int, animated: Bool) {
        let safeIndex = max(0, min(index, items.count))
        items.insert(title ?? "", at: safeIndex)
        // 선택 인덱스 보정 (UISegmentedControl과 동일한 동작)
        if selectedIndex >= safeIndex { selectedIndex += 1 }
        rebuildButtons()
        // 간단한 페이드 애니메이션 옵션
        if animated { animateStackFade() }
    }

    /// 세그먼트 삭제
    public func removeSegment(at index: Int, animated: Bool) {
        guard items.indices.contains(index) else { return }
        items.remove(at: index)
        // 선택 인덱스 보정
        if selectedIndex == index {
            selectedIndex = min(index, max(0, items.count - 1))
        } else if selectedIndex > index {
            selectedIndex -= 1
        }
        rebuildButtons()
        if animated { animateStackFade() }
    }

    /// 모든 세그먼트 삭제
    public func removeAllSegments() {
        items.removeAll()
        selectedIndex = 0
        rebuildButtons()
    }

    /// 세그먼트 활성/비활성
    public func setEnabled(_ enabled: Bool, forSegmentAt index: Int) {
        guard buttons.indices.contains(index) else { return }
        buttons[index].isEnabled = enabled
        buttons[index].alpha = enabled ? 1.0 : 0.5
    }

    public func isEnabledForSegment(at index: Int) -> Bool {
        guard buttons.indices.contains(index) else { return false }
        return buttons[index].isEnabled
    }

    /// UISegmentedControl의 selectedSegmentTintColor와 유사
    public var selectedSegmentTintColor: UIColor {
        get { capsuleBackgroundColor }
        set { capsuleBackgroundColor = newValue }
    }

    // MARK: - Subviews

    private let stackView = UIStackView()
    private let selectionCapsuleView = UIView()
    private var buttons: [UIButton] = []

    // stackView 제약 업데이트용
    private var stackTop: NSLayoutConstraint?
    private var stackLeading: NSLayoutConstraint?
    private var stackTrailing: NSLayoutConstraint?
    private var stackBottom: NSLayoutConstraint?

    // 캡슐 제약
    private var capsuleConstraints: [NSLayoutConstraint] = []

    // MARK: - State flags

    /// 초기 설정 중인지 여부 (valueChanged 이벤트 억제용)
    private var isSettingUp = false

    /// 아직 실제 프레임이 정해지지 않아 캡슐 부착을 뒤로 미룰지 여부
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
        self.items = []
        super.init(coder: coder)
        isSettingUp = true
        configureOnce()
        rebuildButtons()
        isSettingUp = false
    }

    // MARK: - Configuration

    private func configureOnce() {
        backgroundColor = .clear

        // 접근성
        isAccessibilityElement = true
        accessibilityTraits = [.button]
        accessibilityLabel = "Segmented Control"

        // 외곽 알약
        layer.cornerRadius = 999
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
        layer.masksToBounds = true

        // 선택 캡슐
        selectionCapsuleView.backgroundColor = capsuleBackgroundColor
        selectionCapsuleView.layer.cornerRadius = 999
        selectionCapsuleView.layer.borderColor = capsuleBorderColor.cgColor
        selectionCapsuleView.layer.borderWidth = capsuleBorderWidth
        selectionCapsuleView.isUserInteractionEnabled = false
        selectionCapsuleView.translatesAutoresizingMaskIntoConstraints = false

        // 스택
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = segmentSpacing

        // Z-순서: 캡슐이 아래, 버튼이 위
        addSubview(selectionCapsuleView)
        addSubview(stackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        let top = stackView.topAnchor.constraint(equalTo: topAnchor, constant: contentInsets.top)
        let leading = stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: contentInsets.leading)
        let trailing = stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -contentInsets.trailing)
        let bottom = stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -contentInsets.bottom)

        NSLayoutConstraint.activate([
            top, leading, trailing, bottom,
            heightAnchor.constraint(greaterThanOrEqualToConstant: 36)
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
            
            // 최신 API: UIButton.Configuration
            var configuration = UIButton.Configuration.plain()
            configuration.contentInsets = .init(top: 6, leading: 12, bottom: 6, trailing: 12)
            configuration.background.backgroundColor = .clear
            configuration.attributedTitle = AttributedString(title, attributes: .init([.font: font]))
            configuration.baseForegroundColor = (index == selectedIndex) ? selectedTextColor : normalTextColor
            button.configuration = configuration
            
            // 상태 업데이트 핸들러
            button.configurationUpdateHandler = { [weak self] button in
                guard let self = self,
                      let buttonIndex = self.buttons.firstIndex(of: button) else { return }
                var updated = button.configuration ?? .plain()
                updated.attributedTitle = AttributedString(self.items[buttonIndex], attributes: .init([.font: self.font]))
                updated.baseForegroundColor = (buttonIndex == self.selectedIndex) ? self.selectedTextColor : self.normalTextColor
                updated.background.backgroundColor = .clear
                button.configuration = updated
                button.accessibilityTraits = (buttonIndex == self.selectedIndex) ? [.button, .selected] : [.button]
            }
            
            // 탭 처리
            button.addAction(UIAction { [weak self] _ in
                self?.handleTap(on: button)
            }, for: .touchUpInside)
            
            buttons.append(button)
            stackView.addArrangedSubview(button)
        }
        
        // 초기 선택 위치 적용
        // 👉 아직 bounds가 0일 수 있으므로 여기서 바로 attachCapsule 금지
        needsInitialAttach = true
        setNeedsLayout()
        invalidateIntrinsicContentSize()
    }

    // MARK: - Selection Handling

    private func handleTap(on button: UIButton) {
        guard let index = buttons.firstIndex(of: button) else { return }
        if index != selectedIndex {
            setSelectedIndex(index, animated: true)
        } else {
            UIAccessibility.post(notification: .announcement, argument: items[index])
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

        // 레이아웃 강제 적용 (프레임이 존재할 때만)
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
            // 선택 대상이 없으면 캡슐 숨김
            selectionCapsuleView.isHidden = true
            return
        }
        selectionCapsuleView.isHidden = false
        
        // 아직 실제 레이아웃이 안 잡혔다면 캡슐 부착을 나중으로 미룸
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
        layer.cornerRadius = bounds.height / 2
        selectionCapsuleView.layer.cornerRadius = selectionCapsuleView.bounds.height / 2
        
        // 최초 1회, 실제 프레임이 생긴 뒤 캡슐 제약 부착
        if needsInitialAttach, buttons.indices.contains(selectedIndex) {
            needsInitialAttach = false
            attachCapsule(to: buttons[selectedIndex], animated: false)
        }
    }

    public override var intrinsicContentSize: CGSize {
        // 버튼들의 intrinsic 크기에 컨테이너 여백과 간격을 더해 정확한 사이즈 계산
        let buttonHeights = buttons.map { $0.intrinsicContentSize.height }
        let height = (buttonHeights.max() ?? 28) + contentInsets.top + contentInsets.bottom
        let totalButtonsWidth = buttons.reduce(0) { $0 + $1.intrinsicContentSize.width }
        let width = totalButtonsWidth
            + CGFloat(max(0, buttons.count - 1)) * segmentSpacing
            + contentInsets.leading + contentInsets.trailing
        return CGSize(width: max(120, width), height: max(36, height))
    }

    // MARK: - Programmatic API

    /// 코드로 선택 변경
    public func setSelectedIndex(_ index: Int, animated: Bool) {
        let clamped = max(0, min(index, max(0, items.count - 1)))
        guard clamped != selectedIndex else { return }
        selectedIndex = clamped
        updateSelection(animated: animated)
    }

    /// 항목과 선택 인덱스를 한 번에 갱신
    public func setItems(_ newItems: [String], selectedIndex: Int = 0) {
        isSettingUp = true
        self.items = newItems
        self.selectedIndex = max(0, min(selectedIndex, max(0, newItems.count - 1)))
        isSettingUp = false
        needsInitialAttach = true
        setNeedsLayout()
        invalidateIntrinsicContentSize()
    }

    // MARK: - Private

    private func animateStackFade() {
        stackView.alpha = 0
        UIView.animate(withDuration: 0.18) {
            self.stackView.alpha = 1
        }
    }
}
