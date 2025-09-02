//
//  CategoryDetailViewController.swift
//  EventLogger
//
//  Created by Yoon on 9/2/25.
//
import UIKit

import ReactorKit
import RxCocoa
import RxSwift
import SnapKit
import Then

class CategoryDetailViewController: BaseViewController<CategoryDetailReactor> {
    
    // MARK: UI Components
    private let textField = AppTextField()
    
    
    private let bottomButton = UIButton(configuration: .bottomButton).then {
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
    }
    
    override func setupUI() {
        
        view.backgroundColor = .appBackground
        
        view.addSubview(textField)
        view.addSubview(bottomButton)
        
        textField.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.trailing.leading.equalToSuperview().inset(20)
            $0.height.equalTo(42)
        }
        
        bottomButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            $0.height.equalTo(54)
        }
        
    }
    
    override func bind(reactor: CategoryDetailReactor) {
        // 상단 타이틀 & 하단 버튼
        title = reactor.currentState.navTitle
        bottomButton.configuration?.title = reactor.currentState.buttonTitle
        
        // 초기값 세팅
        configureInitialState(reactor: reactor)
        
    }
}

extension CategoryDetailViewController {
    
    private func configureInitialState(reactor: CategoryDetailReactor) {
        
        switch reactor.mode {
        case .create:
            return
        case let .update(category):
            textField.text = category.name
        }
    }
}

