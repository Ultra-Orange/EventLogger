//
//  EventDetailViewController.swift
//  EventLogger
//
//  Created by Yoon on 8/21/25.
//

import Dependencies
import HostingView
import ReactorKit
import RxCocoa
import RxSwift
import SnapKit
import SwiftUI
import Then

class EventDetailViewController: BaseViewController<EventDetailReactor> {
    // MARK: UI Component

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let imageContainerView = UIView().then {
        $0.backgroundColor = .systemGray6
        $0.layer.cornerRadius = 12
    }

    private let imageView = UIImageView()

    private let titleLabel = UILabel().then {
        $0.font = .font20Semibold
        $0.numberOfLines = 2
        $0.lineBreakMode = .byTruncatingTail
        $0.textAlignment = .left
    }

    private let infoItemView = InfoItemView()

    private let memoView = MemoView()

    // MARK: SetupUI

    override func setupUI() {
        view.backgroundColor = .systemBackground
        // 네비게이션 영역
        title = "Event Logger"

        // 스크롤 뷰
        view.addSubview(scrollView)

        scrollView.snp.makeConstraints {
            $0.directionalEdges.equalToSuperview()
        }

        scrollView.addSubview(contentView)

        // 컨텐츠 뷰
        contentView.snp.makeConstraints {
            $0.top.bottom.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.contentLayoutGuide)
            $0.leading.trailing.equalTo(scrollView.frameLayoutGuide).inset(20)
        }

        contentView.addSubview(imageContainerView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(infoItemView)
        contentView.addSubview(memoView)

        // 오토 레이아웃
        imageContainerView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(246)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(imageContainerView.snp.bottom).offset(14)
            $0.leading.trailing.equalToSuperview()
        }

        infoItemView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(14)
            $0.leading.trailing.equalToSuperview()
        }

        memoView.snp.makeConstraints {
            $0.top.equalTo(infoItemView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }

    // MARK: Binding

    override func bind(reactor: EventDetailReactor) {
        // 1회성 데이터 바인딩
        let eventItem = reactor.currentState.eventItem
        titleLabel.text = eventItem.title
        infoItemView.configureView(eventItem: eventItem)
        memoView.configureView(eventItem.memo)

        // TODO: 버튼액션
        infoItemView.addCalendarButton.rx.tap
            .bind {
                print("Add Calendar")
            }
            .disposed(by: disposeBag)

        infoItemView.findDirectionsButton.rx.tap
            .bind {
                print("Find Way")
            }
            .disposed(by: disposeBag)
    }
}

#Preview {
    @Dependency(\.eventItems) var eventItems
    let testItem = eventItems[2]
    let reactor = EventDetailReactor(eventItem: testItem)
    UINavigationController(rootViewController: EventDetailViewController().then {
        $0.reactor = reactor
    })
}
