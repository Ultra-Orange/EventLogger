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
    // TODO: 상단버튼 후변경
    private lazy var editButton = UIBarButtonItem(
        image: UIImage(systemName: "ellipsis"),
        style: .plain,
        target: nil,
        action: nil
    ).then {
        $0.tintColor = .white
    }

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let imageContainerView = UIView().then {
        $0.backgroundColor = .systemGray6
        $0.layer.cornerRadius = 12
    }

    private let imageView = UIImageView().then {
        $0.backgroundColor = .systemGray6
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
    }

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
        navigationItem.rightBarButtonItem = editButton
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

        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(infoItemView)
        contentView.addSubview(memoView)

        // 오토 레이아웃
        imageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(246)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(14)
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
        imageView.image = eventItem.image
        infoItemView.configureView(eventItem: eventItem)
        memoView.configureView(eventItem.memo)

        // TODO: 버튼액션
        editButton.rx.tap
            .map { _ in .moveToEdit(eventItem) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        infoItemView.addCalendarButton.rx.tap
            .map { EventDetailReactor.Action.addToCalendarTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // TODO: 버튼액션
        infoItemView.findDirectionsButton.rx.tap
            .bind {
                print("Find Way")
            }
            .disposed(by: disposeBag)
        
        // TODO: 한 스트림에서 switch로 알럿을 만들지 말고, saveOutcome을 케이스별로 분기된 스트림으로 나눠서, 각각 UIAlertController의 Rx 확장으로 처리하라
        reactor.saveOutcome
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, outcome in
                let alert: UIAlertController
                switch outcome {
                case .success:
                    alert = UIAlertController(
                        title: "캘린더 저장 완료",
                        message: "이 이벤트가 캘린더에 저장되었습니다.",
                        preferredStyle: .alert
                    )
                case .denied:
                    alert = UIAlertController(
                        title: "접근 권한 필요",
                        message: "설정 > 개인정보보호 > 캘린더에서 권한을 허용해주세요.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "설정으로 이동", style: .default) { _ in
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    })
                case .failure(let message):
                    alert = UIAlertController(
                        title: "저장 실패",
                        message: "캘린더 저장 중 오류가 발생했습니다.\n\(message)",
                        preferredStyle: .alert
                    )
                }
                alert.addAction(UIAlertAction(title: "확인", style: .default))
                owner.present(alert, animated: true)
            }
            .disposed(by: disposeBag)
    }
}
