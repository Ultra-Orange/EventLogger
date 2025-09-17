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
import RxRelay
import RxSwift
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

    private let shareButton = UIBarButtonItem(
        image: UIImage(systemName: "square.and.arrow.up"),
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
        navigationItem.rightBarButtonItems = [moreButton, shareButton]

        // UIMenu & Action
        let editAction = UIAction(title: "수정하기", image: UIImage(systemName: "pencil")) { [editActionRelay] _ in
            editActionRelay.accept(())
        }

        let deleteAction = UIAction(title: "삭제하기", image: UIImage(systemName: "trash"), attributes: .destructive) { [deleteActionRelay] _ in
            deleteActionRelay.accept(())
        }

        moreButton.menu = UIMenu(title: "", children: [editAction, deleteAction])
        moreButton.primaryAction = nil // 탭 시 바로 메뉴 표시

        // 스크롤 뷰
        view.addSubview(scrollView)

        scrollView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.bottom.equalToSuperview()
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
        imageView.image = eventItem.image ?? UIImage(named: "DefaultImage")
        infoItemView.configureView(eventItem: eventItem)
        memoView.configureView(eventItem.memo)

        // 메모가 없으면 숨김 처리
        let isMemoEmpty = eventItem.memo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        memoLabel.isHidden = isMemoEmpty
        memoView.isHidden = isMemoEmpty

        // 바인딩
        editActionRelay.map { .moveToEdit(eventItem) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        deleteActionRelay
            .withUnretained(self)
            .flatMap { `self`, _ in
                UIAlertController.rx.alert(on: self, title: "일정 삭제", message: "정말로 이 일정을 삭제할까요?", actions: [
                    .cancel("취소"),
                    .destructive("삭제", payload: .deleteEvent(eventItem)),
                ])
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        infoItemView.addCalendarButton.rx.tap
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .map { EventDetailReactor.Action.addToCalendarTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        infoItemView.findDirectionsButton.rx.tap
            .withUnretained(self)
            .bind { `self`, _ in
                let keyword = self.reactor?.currentState.eventItem.location ?? ""
                reactor.action.onNext(.queryToGoogleMap(keyword))
            }
            .disposed(by: disposeBag)

        shareButton.rx.tap
            .withUnretained(self)
            .bind { `self`, _ in
                guard let eventItem = self.reactor?.currentState.eventItem else { return }

                let text = "[\(eventItem.title)] 참여 예정!✨"

                var activityItems: [Any] = [text]

                // 이미지가 없으면 기본 썸네일로 대체
                let imageToShare = eventItem.image ?? UIImage(named: "DefaultImage")

                if let image = imageToShare,
                   let imageURL = self.makeTempImageURL(image: image)
                {
                    activityItems.append(imageURL)
                }

                let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
                self.present(activityVC, animated: true)
            }
            .disposed(by: disposeBag)

        let saveResult = reactor.pulse(\.$saveResult)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .share()

        // 권한 요청 성공
        saveResult
            .filter { $0 == .success }
            .withUnretained(self)
            .flatMap { `self`, _ in
                UIAlertController.rx.alert(
                    on: self,
                    title: "캘린더 저장 완료",
                    message: "이 이벤트를 캘린더에 저장했어요.",
                    actions: [
                        .action("확인", payload: ()),
                    ]
                )
            }
            .subscribe()
            .disposed(by: disposeBag)

        // 권한 요청 거부
        saveResult
            .filter { $0 == .denied }
            .withUnretained(self)
            .flatMap { `self`, _ in
                UIAlertController.rx.alert(
                    on: self,
                    title: "접근 권한 필요",
                    message: "설정 > 개인정보보호 > 캘린더에서 권한을 허용해주세요.",
                    actions: [
                        .cancel("확인"),
                        .action("설정으로 이동", payload: .openSystemSettings),
                    ]
                )
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // saveResult 획득 실패
        saveResult
            .compactMap {
                if case let .failure(message) = $0 {
                    return message
                }
                return nil
            }
            .withUnretained(self)
            .flatMap { `self`, message in
                UIAlertController.rx.alert(
                    on: self,
                    title: "저장 실패",
                    message: "캘린더 저장 중 오류가 발생했습니다.\n\(message)",
                    actions: [
                        .action("확인", payload: ()),
                    ]
                )
            }
            .subscribe()
            .disposed(by: disposeBag)
    }

    // 공유를 위해 UIImage → 임시 파일 URL 변환기
    private func makeTempImageURL(image: UIImage) -> URL? {
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent(UUID().uuidString + ".jpg")
        if let data = image.jpegData(compressionQuality: 0.8) {
            try? data.write(to: fileURL)
            return fileURL
        }
        return nil
    }
}
