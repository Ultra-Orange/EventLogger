//
//  CategoryEditViewController.swift
//  EventLogger
//
//  Created by Yoon on 8/31/25.
//


import ReactorKit
import RxCocoa
import RxSwift
import SnapKit
import SwiftUI
import Then

class CategoryEditViewController: BaseViewController<CategoryEditReactor> {
    // MARK: UI Component
    
    let navEditButton = UIButton(configuration: .navEdit).then{
        $0.configuration?.title = "편집"
    }
    
    let addButton = UIButton(configuration: .bottomButton).then{
        $0.configuration?.title = "추가하기"
    }
    
    let tmpLabel = UILabel().then {
        $0.text = "여기에 카테고리 편집 추가"
        $0.textColor = .label
    }
    
    // MARK: SetupUI

    override func setupUI() {
        view.backgroundColor = .systemBackground
        title = "카테고리 목록"
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: navEditButton)
        
        view.addSubview(tmpLabel)
        view.addSubview(addButton)
        
        tmpLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        addButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            $0.height.equalTo(54)
        }
        
    }

    // MARK: Binding

    override func bind(reactor: CategoryEditReactor) {
        
                
    }
}
