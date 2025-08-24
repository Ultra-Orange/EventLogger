//
//  ScheduleViewController.swift
//  EventLogger
//
//  Created by Yoon on 8/22/25.
//

import UIKit
import ReactorKit
import RxCocoa
import RxSwift
import SnapKit
import SwiftUI
import Then
import Dependencies

class ScheduleViewController: BaseViewController<ScheduleReactor> {
    
    // MARK: UI Components    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let addImageView = AddImageView()
    private let inputTitleView = TextFieldContainerView()
    private let categoryFieldView = CateogryContainerView()
    private let dateFieldView = DateFieldContainerView()
    private let locationFieldView = LocationFieldContainerView()
    private let artistsFieldView = ArtistsFieldContainerView()
    private let expnsesFieldView = ExpenseFieldContainerView()
    private let memoFieldview = MemoFieldContainerView()
    
    private let bottomButton = UIButton(configuration: .bottomButton)
    
    
    override func setupUI() {
        view.backgroundColor = .systemBackground
        
        // 스크롤 뷰
        view.addSubview(scrollView)

        scrollView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.keyboardLayoutGuide.snp.top)
        }

        scrollView.addSubview(contentView)

        // 컨텐츠 뷰
        contentView.snp.makeConstraints {
            $0.top.bottom.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.contentLayoutGuide)
            $0.leading.trailing.equalTo(scrollView.frameLayoutGuide).inset(20)
        }
        
        contentView.addSubview(addImageView)
        contentView.addSubview(inputTitleView)
        contentView.addSubview(categoryFieldView)
        contentView.addSubview(dateFieldView)
        contentView.addSubview(locationFieldView)
        contentView.addSubview(artistsFieldView)
        contentView.addSubview(expnsesFieldView)
        contentView.addSubview(memoFieldview)
        contentView.addSubview(bottomButton)
        
        // 오토 레이아웃
        addImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.trailing.equalToSuperview()
        }
        
        inputTitleView.snp.makeConstraints {
            $0.top.equalTo(addImageView.snp.bottom).offset(25)
            $0.leading.trailing.equalToSuperview()
        }
        
        categoryFieldView.snp.makeConstraints{
            $0.top.equalTo(inputTitleView.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview()
        }
        
        dateFieldView.snp.makeConstraints {
            $0.top.equalTo(categoryFieldView.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview()
        }
        
        locationFieldView.snp.makeConstraints {
            $0.top.equalTo(dateFieldView.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview()
        }
        artistsFieldView.snp.makeConstraints {
            $0.top.equalTo(locationFieldView.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview()
        }
        
        expnsesFieldView.snp.makeConstraints {
            $0.top.equalTo(artistsFieldView.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview()
        }
        
        memoFieldview.snp.makeConstraints {
            $0.top.equalTo(expnsesFieldView.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview()
        }
        
        bottomButton.snp.makeConstraints {
            $0.top.equalTo(memoFieldview.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(48)
            $0.bottom.equalToSuperview()
        }

    }
    
    override func bind(reactor: ScheduleReactor) {
        title = reactor.currentState.navTitle
        bottomButton.configuration?.title = reactor.currentState.buttonTitle
                
        // 수정의 경우 데이터 주입
        let item = reactor.currentState.eventItem
        guard let item else { return }
        
        inputTitleView.textField.text = item.title
        
    }
}


#Preview {
    @Dependency(\.eventItems) var eventItems
    let testItem = eventItems[2]
//    let reactor = ScheduleReactor(mode: .create)
    let reactor = ScheduleReactor(mode: .update(testItem))
    UINavigationController(rootViewController: ScheduleViewController().then {
        $0.reactor = reactor
    })
}
