//
//  CategoryDropdownButton.swift
//  EventLogger
//
//  Created by 김우성 on 8/27/25.
//

import UIKit
import RxSwift
import RxCocoa

final class CategoryDropDownButton: UIView {
    
    private(set) var categories: [Category] = [] // private(set) var: 읽기는 퍼블릭, 쓰기는 private
    private(set) var selectedCategory: Category?
    
    let selectionRelay = PublishRelay<Category>()
    
    private let button = UIButton(type: .system).then {
        var config = UIButton.Configuration.filled()
        config.title = "선택하세요" // 항상 카테고리 맨 첫번째 것으로 선택되어있도록 바꿔야 할 필요
        config.baseBackgroundColor = .systemGray5
        config.titleAlignment = .leading
        config.imagePlacement = .trailing
        config.imagePadding = 8
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16)
        $0.configuration = config
        $0.contentHorizontalAlignment = .leading
        $0.showsMenuAsPrimaryAction = true
        $0.changesSelectionAsPrimaryAction = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(button)
        button.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    
    // 카테고리/초기값 구성
    func configure(categories: [Category], initial: Category? = nil) {
        self.categories = categories
        self.selectedCategory = initial ?? categories.first
        
        // UIAction 생성
        let actions: [UIAction] = categories.map { category in
            let image = UIImage.circle(diameter: 16, color: category.color)
            let state: UIMenuElement.State = (category == selectedCategory) ? .on : .off
            return UIAction(title: category.name, image: image, state: state) { [weak self] _ in
                self?.updateSelection(to: category)
            }
        }
        
        // 단일 선택 메뉴
        button.menu = UIMenu(title: "", options: [.singleSelection], children: actions)
        
        // 버튼에 초기 선택사항 반영 (PublishRelay이므로 초기 방출은 X)
        applySelectionToButton()
    }
    
    /// 외부에서 선택을 프로그램적으로 변경하고 싶을 때 사용
    func select(category: Category) {
        guard categories.contains(category) else { return }
        updateSelection(to: category)
    }
    
    private func updateSelection(to category: Category) {
        selectedCategory = category
        
        // 메뉴 state 업데이트
        button.menu = UIMenu(
            title: "",
            options: [.singleSelection],
            children: categories.map { choice in
                let image = UIImage.circle(diameter: 16, color: choice.color)
                let state: UIMenuElement.State = (choice == category) ? .on : .off
                return UIAction(title: choice.name, image: image, state: state) { [weak self] _ in
                    self?.updateSelection(to: choice)
                }
            }
        )
        
        applySelectionToButton()
        
        selectionRelay.accept(category)
    }
    
    private func applySelectionToButton() {
        guard var config = button.configuration else { return }
        if let selectedCategory {
            config.title = selectedCategory.name
            config.image = UIImage.circle(diameter: 16, color: selectedCategory.color)
        }
        button.configuration = config
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
