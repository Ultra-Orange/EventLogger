//
//  CategoryContainerView.swift
//  EventLogger
//
//  Created by 김우성 on 8/27/25.
//

import SnapKit
import Then
import UIKit
import RxSwift
import RxCocoa

final class CategoryFieldContainerView: UIView {
    
    // 외부 주입
    var categories: [Category] = [] {
        didSet {
            categoryMenuButton.categories = categories
        }
    }
    
    // 현재 선택
    var selectedCategory: Category? {
        get { categoryMenuButton.selectedCategory }
        set { categoryMenuButton.selectedCategory = newValue }
    }
    
    // 선택 이벤트 (외부 구독용)
    var selectionChanged: Observable<Category> {
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
        
        let categories: [Category] = [
            Category(id: UUID(), name: "팬미팅", position: 0, color: .green),
            Category(id: UUID(), name: "뮤지컬", position: 1, color: .purple),
            Category(id: UUID(), name: "연극", position: 2, color: .yellow),
            Category(id: UUID(), name: "페스티벌", position: 3, color: .blue),
            Category(id: UUID(), name: "콘서트", position: 4, color: .cyan),
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
}

#Preview {
    CategoryFieldContainerView()
}
