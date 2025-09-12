//
//  CategoryFieldContainerView.swift
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
        $0.textColor = .neutral50
    }

    let categoryMenuButton = CategoryDropDownButton().then {
        $0.layer.cornerRadius = 10
        $0.layer.masksToBounds = true
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
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

    var selectedCategory: CategoryItem? {
        return categoryMenuButton.selectedCategory
    }
}
