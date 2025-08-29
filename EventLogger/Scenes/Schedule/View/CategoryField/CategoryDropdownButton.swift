//
//  CategoryDropdownButton.swift
//  EventLogger
//
//  Created by 김우성 on 8/27/25.
//

import RxCocoa
import RxSwift
import UIKit

final class CategoryDropDownButton: UIView {
    private(set) var categories: [CategoryItem] = [] // private(set) var: 읽기는 퍼블릭, 쓰기는 private
    private(set) var selectedCategory: CategoryItem?
    
    let selectionRelay = PublishRelay<CategoryItem>()
    
    private let button = UIButton(type: .system).then {
        var config = UIButton.Configuration.filled()
        config.title = "선택하세요"
        config.baseBackgroundColor = .systemGray5
        config.titleAlignment = .trailing
        config.imagePlacement = .leading
        config.imagePadding = 8
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16)
        $0.configuration = config
        $0.contentHorizontalAlignment = .leading
        $0.showsMenuAsPrimaryAction = true
        $0.changesSelectionAsPrimaryAction = true
    }
    
    private lazy var categoryMenu: UIMenu = {
        let actions: [UIAction] = categories.map { category in
            makeAction(for: category, isSelected: category == selectedCategory)
        }
        return UIMenu(title: "", options: [.singleSelection], children: actions)
    }()
    
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
        button.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    // 카테고리/초기값 구성
    func configure(categories: [CategoryItem], initial: CategoryItem? = nil) {
        self.categories = categories
        // 카테고리 비어있을 경우 방어로직(테스트 때 필요)
        guard !categories.isEmpty else {
            selectedCategory = nil
            let dummy = UIAction(title: "선택 가능한 항목이 없습니다", state: .off) { _ in }
            button.menu = UIMenu(title: "", options: [.displayInline], children: [dummy])
            button.configuration?.title = "선택하세요"
            button.configuration?.image = nil
            return
        }
        selectedCategory = initial ?? categories.first
        
        rebuildMenu() // 메뉴 다시 구성
        applySelectionToButton() // 버튼에 초기 선택사항 반영 (PublishRelay이므로 초기 방출은 X)
    }
    
    private func rebuildMenu() {
        button.menu = UIMenu(
            title: "",
            options: [.singleSelection],
            children: categories.map { choice in
                makeAction(for: choice, isSelected: choice == selectedCategory)
            }
        )
    }
    
    private func makeAction(for category: CategoryItem, isSelected: Bool) -> UIAction {
        let image = UIImage.circle(diameter: 12, color: category.color)
        let state: UIMenuElement.State = isSelected ? .on : .off
        
        return UIAction(title: category.name, image: image, state: state) { [weak self] _ in
            guard let self else { return }
            // 동일한 선택 터치 시 불필요한 이벤트 방지
            guard self.selectedCategory != category else { return }
            self.updateSelection(to: category)
        }
    }
    
    private func updateSelection(to category: CategoryItem) {
        selectedCategory = category
        rebuildMenu()
        applySelectionToButton()
        selectionRelay.accept(category)
    }
    
    private func applySelectionToButton() {
        guard var config = button.configuration else { return }
        if let selectedCategory {
            config.title = selectedCategory.name
            config.image = UIImage.circle(diameter: 12, color: selectedCategory.color)
        }
        button.configuration = config
    }
}
