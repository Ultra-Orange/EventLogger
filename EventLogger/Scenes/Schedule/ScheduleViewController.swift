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
import SwiftUI
import Then
import UIKit

class ScheduleViewController: BaseViewController<ScheduleReactor> {
    // MARK: UI Components

    private let scrollView = UIScrollView()
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
    private let categoryFieldView = CateogryContainerView()
    private let dateFieldView = DateFieldContainerView()
    private let startTimeFiedlView = StartTimeFieldContainerView()
    private let endTimeFieldView = EndTimeFieldContainerView()
    private let locationFieldView = LocationFieldContainerView()
    private let artistsFieldView = ArtistsFieldContainerView()
    private let expnsesFieldView = ExpenseFieldContainerView()
    private let memoFieldview = MemoFieldContainerView()

    private let bottomButton = UIButton(configuration: .bottomButton)

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

        contentView.addSubview(addImageView)
        contentView.addSubview(imageView)
        contentView.addSubview(deleteLabel)
        contentView.addSubview(inputTitleView)
        contentView.addSubview(categoryFieldView)
        contentView.addSubview(dateFieldView)
        contentView.addSubview(startTimeFiedlView)
        contentView.addSubview(endTimeFieldView)
        contentView.addSubview(locationFieldView)
        contentView.addSubview(artistsFieldView)
        contentView.addSubview(expnsesFieldView)
        contentView.addSubview(memoFieldview)
        contentView.addSubview(bottomButton)

        // 삭제 라벨 히든/사용불가 처리
        deleteLabel.isHidden = true
        deleteLabel.isUserInteractionEnabled = true

        // 오토 레이아웃
        addImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.trailing.equalToSuperview()
        }

        imageView.snp.makeConstraints {
            $0.top.equalTo(addImageView.snp.top)
            $0.leading.trailing.equalToSuperview() // 왜 너만? 보라돌이경고?
            $0.height.equalTo(addImageView.snp.height)
        }

        deleteLabel.snp.makeConstraints {
            $0.top.equalTo(addImageView.snp.bottom).offset(10)
            $0.trailing.equalToSuperview()
        }

        inputTitleView.snp.makeConstraints {
            $0.top.equalTo(addImageView.snp.bottom).offset(56)
            $0.leading.trailing.equalToSuperview()
        }

        categoryFieldView.snp.makeConstraints {
            $0.top.equalTo(inputTitleView.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview()
        }

        dateFieldView.snp.makeConstraints {
            $0.top.equalTo(categoryFieldView.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview()
        }

        startTimeFiedlView.snp.makeConstraints {
            $0.top.equalTo(dateFieldView.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview()
        }

        endTimeFieldView.snp.makeConstraints {
            $0.top.equalTo(startTimeFiedlView.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview()
        }

        locationFieldView.snp.makeConstraints {
            $0.top.equalTo(endTimeFieldView.snp.bottom).offset(30)
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

        // 수정의 경우 데이터 주입
        let item = reactor.currentState.eventItem
        guard let item else { return }

        inputTitleView.textField.text = item.title
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

#Preview {
    @Dependency(\.eventItems) var eventItems
    let testItem = eventItems[2]

    let relay = PublishRelay<String>()
//    let reactor = ScheduleReactor(mode: .create)
    let reactor = ScheduleReactor(mode: .update(testItem))
    UINavigationController(rootViewController: ScheduleViewController(selectedLocationRelay: relay).then {
        $0.reactor = reactor
    })
}
