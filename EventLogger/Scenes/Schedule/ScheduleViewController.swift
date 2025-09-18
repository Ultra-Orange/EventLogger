//
//  ScheduleViewController.swift
//  EventLogger
//
//  Created by Yoon on 8/22/25.
//

import CoreData
import Dependencies
import PhotosUI
import ReactorKit
import RxCocoa
import RxGesture
import RxSwift
import SnapKit
import SwiftData
import SwiftUI
import Then
import UIKit

class ScheduleViewController: BaseViewController<ScheduleReactor> {
    // MARK: UI Components

    private let scrollView = UIScrollView().then {
        $0.keyboardDismissMode = .interactive // 키보드 드래그로 내릴 수 있게 함
        $0.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 0)
    }

    private let contentView = UIView()

    private let addImageView = AddImageView()
    private let imageView = UIImageView().then {
        $0.clipsToBounds = true
        $0.backgroundColor = .clear
        $0.contentMode = .scaleAspectFit
    }

    private let removeImageButton = UIButton(configuration: .removeImgButton).then {
        $0.configuration?.title = "이미지 삭제"
    }

    private let inputTitleView = TitleFieldContainerView()
    private let categoryFieldView = CategoryFieldContainerView()
    private let dateRangeFieldView = DateRangeFieldContainerView()
    private let locationFieldView = LocationFieldContainerView()
    private let artistsFieldView = ArtistsFieldContainerView()
    private let expenseFieldView = ExpenseFieldContainerView()
    private let memoFieldView = MemoFieldContainerView()

    private let bottomButton = GlowButton(title: "")

    private let selectedLocationRelay: PublishRelay<String>

    let notification = NSPersistentCloudKitContainer.eventChangedNotification

    // MARK: LifeCycle

    init(selectedLocationRelay: PublishRelay<String>) {
        self.selectedLocationRelay = selectedLocationRelay
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setupUI() {
        view.backgroundColor = .systemBackground

        // 뷰 주입
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        view.addSubview(bottomButton)

        scrollView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.lessThanOrEqualTo(bottomButton.snp.top)
            $0.bottom.equalTo(view.keyboardLayoutGuide.snp.top).priority(.low)
        }

        // 컨텐츠 뷰
        contentView.snp.makeConstraints {
            $0.top.bottom.equalTo(scrollView.contentLayoutGuide)
            // 의도적으로 모호하게 만들어서 시스템이 자동으로 offset 올려주는거 막기 위해 width 주석처리
//            $0.width.equalTo(scrollView.contentLayoutGuide)
            $0.leading.trailing.equalTo(scrollView.frameLayoutGuide).inset(20)
        }

        contentView.addSubview(removeImageButton)
        contentView.addSubview(addImageView)
        contentView.addSubview(imageView)
        contentView.addSubview(inputTitleView)
        contentView.addSubview(categoryFieldView)
        contentView.addSubview(dateRangeFieldView)
        contentView.addSubview(locationFieldView)
        contentView.addSubview(artistsFieldView)
        contentView.addSubview(expenseFieldView)
        contentView.addSubview(memoFieldView)

        // 오토 레이아웃
        removeImageButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.trailing.equalToSuperview()
        }

        addImageView.snp.makeConstraints {
            $0.top.equalTo(removeImageButton.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
        }

        imageView.snp.makeConstraints {
            $0.top.equalTo(addImageView.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(addImageView.snp.height)
        }

        inputTitleView.snp.makeConstraints {
            $0.top.equalTo(addImageView.snp.bottom).offset(56)
            $0.leading.trailing.equalToSuperview()
        }

        categoryFieldView.snp.makeConstraints {
            $0.top.equalTo(inputTitleView.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview()
        }

        dateRangeFieldView.snp.makeConstraints {
            $0.top.equalTo(categoryFieldView.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview()
        }

        locationFieldView.snp.makeConstraints {
            $0.top.equalTo(dateRangeFieldView.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview()
        }

        artistsFieldView.snp.makeConstraints {
            $0.top.equalTo(locationFieldView.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview()
        }

        expenseFieldView.snp.makeConstraints {
            $0.top.equalTo(artistsFieldView.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview()
        }

        memoFieldView.snp.makeConstraints {
            $0.top.equalTo(expenseFieldView.snp.bottom).offset(30)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        bottomButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(54)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-10)
        }
    }

    override func bind(reactor: ScheduleReactor) {
        // 초기값 세팅
        reactor.state
            .take(1)
            .bind { [weak self] state in
                // 상단 타이틀 & 하단 버튼
                self?.title = state.navTitle
                self?.bottomButton.setTitle(state.buttonTitle, for: .normal)
                // 초기값 바인딩
                self?.configureInitialState(state: state)
            }
            .disposed(by: disposeBag)

        NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillShowNotification)
            .compactMap(\.userInfo)
            .bind { [weak self] userInfo in
                guard let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                    return
                }
                guard let self, let responder = view.findFirstResponder() as? UIView else {
                    return
                }

                let frame = responder.convert(responder.bounds, to: view)
                let offset = CGPoint(
                    x: scrollView.contentOffset.x,
                    y: max(scrollView.contentOffset.y, max(0, frame.maxY + scrollView.contentOffset.y - keyboardFrame.minY + 30))
                )
                scrollView.setContentOffset(offset, animated: true)

                let intersection = keyboardFrame.intersection(scrollView.frame)
                scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: intersection.height + 40, right: 0)
            }
            .disposed(by: disposeBag)

        // 뷰 등장시점 포커싱
        rx.viewDidAppear.map { _ in }
            .withLatestFrom(reactor.state.map(\.mode))
            .filter { $0 == .create }
            .take(1)
            .bind { [inputTitleView] _ in
                inputTitleView.textField.becomeFirstResponder()
            }
            .disposed(by: disposeBag)

        // 에디팅 끝나는지 구독
        let editingDidEnd = inputTitleView.textField.rx
            .controlEvent(.editingDidEnd)
            .withLatestFrom(inputTitleView.textField.rx.text.orEmpty)
            .share()

        // 제목란이 유효한지 구독
        let isTitleValid = Observable.merge(
            inputTitleView.textField.rx.text.orEmpty.asObservable(),
            editingDidEnd
        )
        .map { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        .share(replay: 1)

        // 카테고리 존재 여부
        let hasCategory = reactor.state
            .map(\.categories)
            .map { !$0.isEmpty }

        // 사용자에게 알려줄 경고라벨 hidden 처리
        isTitleValid
            .skip(until: inputTitleView.textField.rx.controlEvent(.editingDidBegin))
            .startWith(true)
            .bind(to: inputTitleView.alertlabel.rx.isHidden)
            .disposed(by: disposeBag)

        hasCategory.bind(to: categoryFieldView.alertlabel.rx.isHidden)
            .disposed(by: disposeBag)

        // 버튼 활성 바인딩 (제목 적었고, 카테고리 0개 아닐 때) (UIButton은 isEnabled=false면 탭 이벤트도 막힘)
        Observable
            .combineLatest(isTitleValid, hasCategory) { $0 && $1 }
            .bind(to: bottomButton.rx.isEnabled)
            .disposed(by: disposeBag)

        // 장소 선택 바인딩
        reactor.state.map { $0.selectedLocation }
            .map { $0.isEmpty ? "장소를 입력하세요" : $0 }
            .bind(to: locationFieldView.textLabel.rx.text)
            .disposed(by: disposeBag)

        // 장소 선택 empty면 버튼 히든
        reactor.state
            .map(\.selectedLocation)
            .distinctUntilChanged()
            .map { $0.isEmpty }
            .bind(to: locationFieldView.closeIcon.rx.isHidden)
            .disposed(by: disposeBag)

        // 이미지 뷰 탭 제스쳐
        addImageView.rx.tapGesture()
            .when(.recognized)
            .map { _ -> PHPickerViewController in
                var configuration = PHPickerConfiguration()
                configuration.filter = .images
                configuration.selectionLimit = 1
                return PHPickerViewController(configuration: configuration)
            }
            .withUnretained(self)
            .do(onNext: { $0.present($1, animated: true) })
            .flatMap { $1.rx.selectedImages }
            .compactMap(\.first)
            .observe(on: MainScheduler.instance)
            .bind { [weak self] image in
                self?.imageView.image = image
                self?.removeImageButton.isHidden = false
            }
            .disposed(by: disposeBag)

        // 이미지 삭제 버튼
        removeImageButton.rx.tap
            .bind { [weak self] _ in
                self?.imageView.image = nil
                self?.removeImageButton.isHidden = true
            }
            .disposed(by: disposeBag)

        // 장소 입력 필드 탭 제스처
        locationFieldView.inputField.rx.tapGesture()
            .when(.recognized)
            .do(onNext: { [artistsFieldView] _ in
                artistsFieldView.tagsField.textField.resignFirstResponder()
            })
            .withLatestFrom(reactor.state.map(\.selectedLocation))
            .map { AppStep.locationSearch($0) }
            .bind(to: reactor.steps)
            .disposed(by: disposeBag)

        // 장소 입력 취소 탭 제스처
        locationFieldView.closeIcon.rx.tapGesture()
            .when(.recognized)
            .map { _ in .selectLocation("") }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // 장소 선택 릴레이
        selectedLocationRelay
            .map { title in .selectLocation(title) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // 메모뷰 스크롤
        memoFieldView.textView.rx.didBeginEditing
            .bind(onNext: { [weak self] in
                guard let self else { return }
                self.scrollViewToShowWhole(self.memoFieldView.textView)
            })
            .disposed(by: disposeBag)

        // 비용 텍스트필드 관련 처리
        var characterSets = CharacterSet.decimalDigits
        characterSets.insert(".")

        let expenseRelay = BehaviorRelay<Double>(value: 0)
        let expensText = expenseFieldView.textField.rx.text.orEmpty
            .map { $0.components(separatedBy: characterSets.inverted).joined() }
            .share()

        expensText
            .map { String($0.prefix(15)) } // 최대 15자리까지 입력되도록 제한
            .map { Double($0) ?? 0 }
            .bind(to: expenseRelay)
            .disposed(by: disposeBag)

        expensText
            .map { $0.count <= 15 } // 15자 이하이면 경고라벨 히든
            .startWith(true)
            .bind(to: expenseFieldView.alertlabel.rx.isHidden)
            .disposed(by: disposeBag)

        expenseRelay
            .map { $0 == .zero ? "" : $0.formatted(.number) }
            //            .distinctUntilChanged() // distinctUntilChanged 켜놓으면 .도 입력 불가
            .bind(to: expenseFieldView.textField.rx.text)
            .disposed(by: disposeBag)

        // 하단버튼 탭
        bottomButton.rx.tap
            .withLatestFrom(expenseRelay)
            .bind { [weak self] expense in
                guard let self, let reactor = self.reactor else { return }
                let payload = EventPayload(
                    title: inputTitleView.textField.text ?? "",
                    categoryId: categoryFieldView.selectedCategory?.id ?? UUID(),
                    image: imageView.image,
                    startTime: dateRangeFieldView.startDate,
                    endTime: dateRangeFieldView.endDate,
                    location: reactor.currentState.selectedLocation.isEmpty
                        ? nil
                        : reactor.currentState.selectedLocation,
                    artists: artistsFieldView.tagsField.tags.map(\.text),
                    expense: expense,
                    currency: .KRW, // MVP 기준 고정
                    memo: memoFieldView.textView.text ?? ""
                )

                reactor.action.onNext(.sendEventPayload(payload))
            }
            .disposed(by: disposeBag)

        // 카테고리 바인딩
        reactor.state.map(\.categories)
            .distinctUntilChanged()
            .bind { [categoryFieldView] categories in
                categoryFieldView.configure(categories: categories, initial: categoryFieldView.selectedCategory)
            }
            .disposed(by: disposeBag)

        categoryFieldView.categoryMenuButton.newCategoryRelay
            .map { .newCategory }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // notification 수신(클라우드킷 연동위해 필요)
        Observable.merge(
            rx.viewWillAppear.map { _ in },
            NotificationCenter.default.rx.notification(notification).map { _ in }
        )
        .map { _ in .reloadCategories }
        .bind(to: reactor.action)
        .disposed(by: disposeBag)
    }

    // 최초값 바인딩용 함수
    private func configureInitialState(state: ScheduleReactor.State) {
        // 공통 카테고리 & 아이템
        let categories = state.categories

        switch state.mode {
        case .create:
            // 신규등록은 카테고리 목록만 세팅
            categoryFieldView.configure(categories: categories)
            removeImageButton.isHidden = true
        case let .update(item):
            // 이미지
            imageView.image = item.image
            removeImageButton.isHidden = (item.image == nil)

            // 제목
            inputTitleView.textField.text = item.title

            // 카테고리 세팅
            let selectedCategory = categories.first { $0.id == item.categoryId }
            categoryFieldView.configure(categories: categories, initial: selectedCategory)

            // 날짜 및 시간
            dateRangeFieldView.startDate = item.startTime
            dateRangeFieldView.endDate = item.endTime

            // 장소 (리액터에서 바인딩)

            // 아티스트
            item.artists.forEach { artistsFieldView.tagsField.addTag($0) }

            // 비용
            expenseFieldView.textField.text = item.expense.formatted(.number)

            // 메모
            memoFieldView.textView.text = item.memo
        }
    }
}

extension ScheduleViewController {
    /// 특정 서브뷰 전체가 보이도록 스크롤(상하 10pt 여유)
    func scrollViewToShowWhole(_ target: UIView, verticalPadding _: CGFloat = 10, animated: Bool = true) {
        let contentHeight = scrollView.contentSize.height

        let screenHeight = view.bounds.height
        let keyboardHeight = view.keyboardLayoutGuide.layoutFrame.height
        let visibleHeight = screenHeight - keyboardHeight

        // target 뷰가 scrollView 좌표계에서 시작하는 Y 위치
        let targetY = target.convert(target.bounds, to: scrollView).origin.y

        scrollView.setContentOffset(CGPoint(x: 0, y: contentHeight - visibleHeight + contentHeight - targetY), animated: animated)
        // 800이 아니라 전체 스크롤뷰 높이
    }
}

// 이벤트 등록/수정 데이터 전달용 객체
struct EventPayload {
    var title: String
    var categoryId: UUID
    var image: UIImage?
    var startTime: Date
    var endTime: Date
    var location: String?
    var artists: [String]
    var expense: Double
    var currency: Currency
    var memo: String
}
