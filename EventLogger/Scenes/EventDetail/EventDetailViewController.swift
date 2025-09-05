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
import RxRelay
import SnapKit
import SwiftUI
import Then

class EventDetailViewController: BaseViewController<EventDetailReactor> {
    // MARK: UI Component
    
    private let moreButton = UIBarButtonItem(
        image: UIImage(systemName: "ellipsis"),
        style: .plain,
        target: nil,
        action: nil
    ).then {
        $0.tintColor = .neutral50
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
        $0.contentMode = .scaleAspectFit
    }

    private let titleLabel = UILabel().then {
        $0.font = .font28Bold
        $0.numberOfLines = 2
        $0.lineBreakMode = .byTruncatingTail
        $0.textAlignment = .left
    }

    private let infoItemView = InfoItemView()
    
    private let memoLabel = UILabel().then {
        $0.text = "메모"
        $0.font = .font13Regular
        $0.textColor = .label
    }
    private let memoView = MemoView()

    private let editActionRelay = PublishRelay<Void>()
    private let deleteActionRelay = PublishRelay<Void>()
    
    // MARK: SetupUI

    override func setupUI() {
        view.backgroundColor = .systemBackground
        // 네비게이션 영역
        title = "이벤트 상세"
        navigationItem.rightBarButtonItem = moreButton
        
        // UIMenu & Action
        let editAction = UIAction(title: "수정하기", image: UIImage(systemName: "pencil")) { [editActionRelay] _ in
            editActionRelay.accept(())
        }

        let deleteAction = UIAction(title: "삭제하기", image: UIImage(systemName: "trash"), attributes: .destructive) {  [deleteActionRelay] _ in
            deleteActionRelay.accept(())
        }
        
        moreButton.menu = UIMenu(title: "", children: [editAction, deleteAction])
        moreButton.primaryAction = nil   // 탭 시 바로 메뉴 표시
        
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
        contentView.addSubview(memoLabel)
        contentView.addSubview(memoView)

        // 오토 레이아웃
        imageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(imageView.snp.width)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
        }

        infoItemView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
        }
        
        memoLabel.snp.makeConstraints {
            $0.top.equalTo(infoItemView.snp.bottom).offset(30)
            $0.leading.trailing.equalTo(memoView).inset(16)
        }

        memoView.snp.makeConstraints {
            $0.top.equalTo(memoLabel.snp.bottom).offset(8)
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
        
        editActionRelay.map { .moveToEdit(eventItem) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        deleteActionRelay
            .withUnretained(self)
            .flatMap { `self`, _ in
                UIAlertController.rx.alert(on: self, title: "일정 삭제", message: "정말로 이 일정을 삭제하시겠습니까?", actions: [
                    .cancel("취소"),
                    .destructive("삭제", payload: .deleteEvent(eventItem.id)),
                ])
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        infoItemView.addCalendarButton.rx.tap
            .map { EventDetailReactor.Action.addToCalendarTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // TODO: 버튼액션
        infoItemView.findDirectionsButton.rx.tap
            .withUnretained(self)
            .bind { `self`, _ in
                let keyword = self.reactor?.currentState.eventItem.location ?? ""
                self.openInGoogleMaps(keyword: keyword)
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
    
    private func openInGoogleMaps(keyword: String) {
        // URL은 공백이나 한글 같은 특수문자를 직접 포함할 수 없기 때문에 addingPercentEncoding으로 변환
        let encoded = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? keyword
        
        // 1) 구글맵 앱으로 열기
        if let appURL = URL(string: "comgooglemaps://?q=\(encoded)"),
           UIApplication.shared.canOpenURL(appURL) {
            UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
            return
        }
        
        // 2) 앱이 없으면 웹으로 열기
        if let webURL = URL(string: "https://www.google.com/maps/search/?api=1&query=\(encoded)") {
            UIApplication.shared.open(webURL, options: [:], completionHandler: nil)
        }
    }

}
