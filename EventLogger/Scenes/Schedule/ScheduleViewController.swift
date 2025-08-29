//
//  ScheduleViewController.swift
//  EventLogger
//
//  Created by Yoon on 8/22/25.
//

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
    }
    
    private let contentView = UIView()
    
    private let addImageView = AddImageView()
    private let imageView = UIImageView().then {
        $0.clipsToBounds = true
        $0.backgroundColor = .clear
        $0.contentMode = .scaleAspectFit
    }
    
    private let deleteLabel = UILabel().then {
        $0.text = "이미지 삭제"
        $0.font = .font12Regular
    }
    
    private let inputTitleView = TitleFieldContainerView()
    private let categoryFieldView = CategoryFieldContainerView()
    private let dateRangeFieldView = DateRangeFieldContainerView()
    private let locationFieldView = LocationFieldContainerView()
    private let artistsFieldView = ArtistsFieldContainerView()
    private let expenseFieldView = ExpenseFieldContainerView()
    private let memoFieldView = MemoFieldContainerView()
    
    private let bottomButton = UIButton(configuration: .bottomButton).then {
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
    }
    
    private let selectedLocationRelay: PublishRelay<String>
    
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
        
        contentView.addSubview(deleteLabel)
        contentView.addSubview(addImageView)
        contentView.addSubview(imageView)
        contentView.addSubview(inputTitleView)
        contentView.addSubview(categoryFieldView)
        contentView.addSubview(dateRangeFieldView)
        contentView.addSubview(locationFieldView)
        contentView.addSubview(artistsFieldView)
        contentView.addSubview(expenseFieldView)
        contentView.addSubview(memoFieldView)
        contentView.addSubview(bottomButton)
        
        // 삭제 라벨 히든/사용불가 처리
        deleteLabel.isHidden = true
        deleteLabel.isUserInteractionEnabled = true
        
        // 오토 레이아웃
        deleteLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.trailing.equalToSuperview()
        }
        
        addImageView.snp.makeConstraints {
            $0.top.equalTo(deleteLabel.snp.bottom).offset(8)
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
            $0.leading.trailing.equalToSuperview()
        }
        
        bottomButton.snp.makeConstraints {
            $0.top.equalTo(memoFieldView.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(54)
            $0.bottom.equalToSuperview().inset(10)
        }
    }
    
    override func bind(reactor: ScheduleReactor) {
        // 상단 타이틀 & 하단 버튼
        title = reactor.currentState.navTitle
        bottomButton.configuration?.title = reactor.currentState.buttonTitle
        
        // 초기값 세팅
        configureInitialState(reactor: reactor)
        
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
            .bind { [weak self] _ in
                self?.presentImagePicker()
            }
            .disposed(by: disposeBag)
        
        // 이미지 삭제 라벨
        deleteLabel.rx.tapGesture()
            .when(.recognized)
            .bind { [weak self] _ in
                self?.imageView.image = nil
                self?.deleteLabel.isHidden = true
            }
            .disposed(by: disposeBag)
        
        // 장소 입력 필드 탭 제스처
        locationFieldView.inputField.rx.tapGesture()
            .when(.recognized)
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
        
        // 하단버튼 탭
        bottomButton.rx.tap
            .bind { [weak self] _ in
                guard let self, let reactor = self.reactor else { return }
                let image = imageView.image
                let title = inputTitleView.textField.text ?? ""
                let categoryId = categoryFieldView.selectedCategory?.id ?? UUID() // 문법상 옵셔널 바인딩
                let start = dateRangeFieldView.startDate
                let end = dateRangeFieldView.endDate
                let location = reactor.currentState.selectedLocation
                let artists = artistsFieldView.tagsField.tags.map(\.text)
                let memo = memoFieldView.textView.text ?? ""
                
                let formatter = NumberFormatter().then {
                    $0.numberStyle = .decimal
                }
                let expense = expenseFieldView.textField.text.flatMap { formatter.number(from: $0) }.map(\.doubleValue) ?? 0
                
                let item = EventItem(
                    id: UUID(),
                    title: title,
                    categoryId: categoryId,
                    image: image,
                    startTime: start,
                    endTime: end,
                    location: location.isEmpty ? nil : location,
                    artists: artists,
                    expense: expense,
                    currency: .KRW, // MVP 기준 고정
                    memo: memo
                )
                
                reactor.action.onNext(.sendEventItem(item))
            }
            .disposed(by: disposeBag)
    }
    
    private func configureInitialState(reactor: ScheduleReactor) {
        // 공통 카테고리 & 아이템
        let categories = reactor.currentState.categories
        
        switch reactor.mode {
        case .create:
            // 신규등록은 카테고리 목록만 세팅
            categoryFieldView.configure(categories: categories)
        case let .update(item):
            // TODO: 이미지
            
            // 제목
            inputTitleView.textField.text = item.title
            
            // 카테고리 세팅
            let selectedCategory = categories.first { $0.id == item.categoryId }
            categoryFieldView.configure(categories: categories, initial: selectedCategory)
            
            // 날짜 및 시간
            dateRangeFieldView.startDate = item.startTime
            dateRangeFieldView.endDate = item.endTime
            
            // 장소
            if let location = item.location {
                reactor.action.onNext(.selectLocation(location))
            }
            
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

// 이미지피커 Delegate
extension ScheduleViewController: PHPickerViewControllerDelegate {
    private func presentImagePicker() {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = 1
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let provider = results.first?.itemProvider else { return }
        
        if provider.canLoadObject(ofClass: UIImage.self) {
            provider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
                guard let self, let uiImage = image as? UIImage else { return }
                DispatchQueue.main.async {
                    self.imageView.image = uiImage
                    self.deleteLabel.isHidden = false
                }
            }
        }
        print("사진 선택 완료, 결과: \(results)")
    }
}


