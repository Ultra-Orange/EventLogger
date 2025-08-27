//
//  CategoryDropdownButton.swift
//  EventLogger
//
//  Created by 김우성 on 8/27/25.
//

import UIKit
import RxSwift
import RxCocoa

final class CategoryDropDownButton: UIButton {
    
    var categories: [Category] = [] { didSet { rebuildMenu() } }
    var selectedCategory: Category? { didSet { applySelection(animated: true) } }
    var placeholder: String = "선택하세요" { didSet { applySelection(animated: false) } }
    
    let selectionRelay = PublishRelay<Category>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupBehavior()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .systemGray5
        config.baseForegroundColor = .white
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16)
        config.cornerStyle = .large
        config.imagePlacement = .trailing
        config.imagePadding = 8
        config.image = UIImage(systemName: "chevron.up.chevron.down")
        self.configuration = config
        
        layer.cornerRadius = 10
        clipsToBounds = true
        
        // 초기 텍스트
        applySelection(animated: false)
        setNeedsUpdateConfiguration()
    }
    
    private func setupBehavior() {
        showsMenuAsPrimaryAction = true // 탭하면 메뉴 바로 표시
    }
    
    private func rebuildMenu() {
        let items = categories.sorted { $0.position < $1.position }
        
        let actions: [UIAction] = items.map { [weak self] category in
            guard let self else { return UIAction(title: category.name, handler: { _ in }) }
            
            let checked = (category == self.selectedCategory)
            let colorDot = UIImage.circle(diameter: 10, color: category.color)
            
            return UIAction(title: category.name, image: colorDot, state: checked ? .on : .off) { _ in
                self.selectedCategory = category
                self.selectionRelay.accept(category)
            }
        }
        
        self.menu = UIMenu(
            title: "",
            options: .displayInline,
            children: actions.isEmpty ? [UIAction(title: "항목 없음", attributes: [.disabled], handler: { _ in })] : actions
        )
    }
    
    private func applySelection(animated: Bool) {
        var config = self.configuration ?? .filled()
        let title = selectedCategory?.name ?? placeholder
        config.title = title
        config.attributedTitle = AttributedString(title, attributes: .init([
            .font: UIFont.font17Regular,
            .foregroundColor: UIColor.white
        ]))
        config.image = UIImage(systemName: "chevron.up.chevron.down")
        self.configuration = config
        
        // 살짝 탭 피드백 애니메이션 (?)
        if animated {
            UIView.animate(withDuration: 0.08, animations: { self.alpha = 0.85 }) { _ in
                UIView.animate(withDuration: 0.12) { self.alpha = 1 }
            }
        }
        
        // 선택이 바뀌면 체크 상태 반영을 위해 메뉴 재생성
        rebuildMenu()
    }
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: 44) // 텍스트필드처럼 44 고정 높이
    }
}

private extension UIImage {
    // 카테고리 색 점 아이콘 생성 유틸
    static func circle(diameter: CGFloat, color: UIColor) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = UIScreen.main.scale
        let renderer = UIGraphicsImageRenderer(size: .init(width: diameter, height: diameter), format: format)
        return renderer.image { _ in
            let rect = CGRect(origin: .zero, size: .init(width: diameter, height: diameter))
            color.setFill()
            UIBezierPath(ovalIn: rect).fill()
        }.withRenderingMode(.alwaysOriginal)
    }
}
