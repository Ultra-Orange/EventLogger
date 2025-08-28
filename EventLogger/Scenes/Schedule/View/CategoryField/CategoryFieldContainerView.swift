//
//  CategoryContainerView.swift
//  EventLogger
//
//  Created by 김우성 on 8/27/25.
//

import RxCocoa
import RxSwift
import SnapKit
import Then
import UIKit

final class CategoryFieldContainerView: UIView {
    // 선택 이벤트 (외부 구독용)
    var selectionChanged: Observable<CategoryItem> {
        categoryMenuButton.selectionRelay.asObservable()
    }
    
    let sectionHeader = UILabel().then {
        $0.text = "카테고리"
        $0.font = .font13Regular
        $0.textColor = .white
    }
    
    let categoryMenuButton = CategoryDropDownButton().then {
        $0.layer.cornerRadius = 10
        $0.layer.masksToBounds = true
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        
        let categories: [CategoryItem] = [
            CategoryItem(name: "팬미팅", position: 0, colorId: 0),
            CategoryItem(name: "뮤지컬", position: 1, colorId: 1),
            CategoryItem(name: "연극", position: 2, colorId: 2),
            CategoryItem(name: "페스티벌", position: 3, colorId: 3),
            CategoryItem(name: "콘서트", position: 4, colorId: 4),
        ]
        
        categoryMenuButton.configure(categories: categories)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(sectionHeader)
        addSubview(categoryMenuButton)

        sectionHeader.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        categoryMenuButton.snp.makeConstraints {
            $0.top.equalTo(sectionHeader.snp.bottom).offset(8)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(44)
        }
    }
    
    func configure(categories: [CategoryItem], initial: CategoryItem? = nil) {
        categoryMenuButton.configure(categories: categories, initial: initial)
    }
    
    var selecatedCategory: CategoryItem? {
        return categoryMenuButton.selectedCategory
    }
    
    func select(category: CategoryItem) {
        categoryMenuButton.select(category: category)
    }
}

//#Preview {
//    let view = CategoryFieldContainerView()
//    // Preview에서는 임시로 샘플 주입
//    let categories: [Category] = [
//        Category(id: UUID(), name: "팬미팅", position: 0, colorId: .green),
//        Category(id: UUID(), name: "뮤지컬", position: 1, colorId: .purple),
//        Category(id: UUID(), name: "연극", position: 2, colorId: .yellow),
//        Category(id: UUID(), name: "페스티벌", position: 3, colorId: .blue),
//        Category(id: UUID(), name: "콘서트", position: 4, colorId: .cyan),
//    ]
//    view.configure(categories: categories, initial: categories.first)
//    return view
//}
