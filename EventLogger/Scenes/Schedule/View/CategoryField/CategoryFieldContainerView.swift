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
            dropdown.categories = categories
        }
    }
    
    // 현재 선택
    var selectedCategory: Category? {
        get { dropdown.selectedCategory }
        set { dropdown.selectedCategory = newValue }
    }
    
    // 선택 이벤트 (외부 구독용)
    var selectionChanged: Observable<Category> {
        dropdown.selectionRelay.asObservable()
    }
    
    let sectionHeader = UILabel().then {
        $0.text = "카테고리"
        $0.font = .font13Regular
        $0.textColor = .white
    }
    
    private let dropdown = CategoryDropDownButton()

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
        addSubview(dropdown)

        sectionHeader.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        dropdown.snp.makeConstraints {
            $0.top.equalTo(sectionHeader.snp.bottom).offset(8)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(44)
        }
    }
}

#Preview {
    CategoryFieldContainerView()
}
