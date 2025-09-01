//
//  InfoItemView.swift
//  EventLogger
//
//  Created by Yoon on 8/22/25.
//

import SnapKit
import Then
import UIKit
import Dependencies

// 정보 카드 부분 뷰
class InfoItemView: UIView {
    // 정보 영역 컨테이너 뷰
    private let infoCardView = UIView().then {
        $0.backgroundColor = .systemGray6
        $0.layer.cornerRadius = 12
    }

    // MARK: Label

    private let dateLabel = UILabel().then {
        $0.font = .font17Regular
    }

    private let categoryLabel = UILabel().then {
        $0.font = .font17Regular
    }

    private let timelabel = UILabel().then {
        $0.font = .font17Regular
    }

    private let locationLabel = UILabel().then {
        $0.font = .font17Regular
    }

    private let artistsLabel = UILabel().then {
        $0.font = .font17Regular
    }

    private let expenseLabel = UILabel().then {
        $0.font = .font17Regular
    }

    // MARK: SF Symbol

    private let calendarIcon = UIImageView(image: UIImage(systemName: "calendar", withConfiguration: .font17Regular))
    private let tagIcon = UIImageView(image: UIImage(systemName: "tag", withConfiguration: .font17Regular))
    private let clockIcon = UIImageView(image: UIImage(systemName: "clock", withConfiguration: .font17Regular))
    private let mapPinIcon = UIImageView(image: UIImage(systemName: "mappin.and.ellipse", withConfiguration: .font17Regular))
    private let personIcon = UIImageView(image: UIImage(systemName: "person", withConfiguration: .font17Regular))
    private let moneysignIcon = UIImageView(image: UIImage(systemName: "wonsign.circle", withConfiguration: .font17Regular))

    // MARK: Button

    let addCalendarButton = UIButton(configuration: .defaultButton).then {
        $0.configuration?.title = "캘린더에 추가"
    }

    let findDirectionsButton = UIButton(configuration: .defaultColorReversed).then {
        $0.configuration?.title = "길 찾기"
    }

    // MARK: StackView

    private let buttonStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 16
        $0.alignment = .fill
        $0.distribution = .fillEqually
    }

    // MARK: init

    override init(frame: CGRect) {
        super.init(frame: frame)

        // 뷰 주입
        addSubview(infoCardView)
        infoCardView.addSubview(dateLabel)
        infoCardView.addSubview(categoryLabel)
        infoCardView.addSubview(timelabel)
        infoCardView.addSubview(locationLabel)
        infoCardView.addSubview(artistsLabel)
        infoCardView.addSubview(expenseLabel)
        infoCardView.addSubview(calendarIcon)
        infoCardView.addSubview(tagIcon)
        infoCardView.addSubview(clockIcon)
        infoCardView.addSubview(mapPinIcon)
        infoCardView.addSubview(personIcon)
        infoCardView.addSubview(moneysignIcon)

        buttonStackView.addArrangedSubview(addCalendarButton)
        buttonStackView.addArrangedSubview(findDirectionsButton)

        infoCardView.addSubview(buttonStackView)

        // 오토 레이아웃
        infoCardView.snp.makeConstraints {
            $0.directionalEdges.equalToSuperview()
        }

        calendarIcon.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().offset(20)
        }

        dateLabel.snp.makeConstraints {
            $0.top.equalTo(calendarIcon)
            $0.leading.equalTo(calendarIcon.snp.trailing).offset(10)
        }

        tagIcon.snp.makeConstraints {
            $0.top.equalTo(calendarIcon.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(20)
        }

        categoryLabel.snp.makeConstraints {
            $0.top.equalTo(tagIcon)
            $0.leading.equalTo(tagIcon.snp.trailing).offset(8)
        }

        clockIcon.snp.makeConstraints {
            $0.top.equalTo(tagIcon.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(20)
        }

        timelabel.snp.makeConstraints {
            $0.top.equalTo(clockIcon)
            $0.leading.equalTo(clockIcon.snp.trailing).offset(11)
        }

        mapPinIcon.snp.makeConstraints {
            $0.top.equalTo(clockIcon.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(20)
        }

        locationLabel.snp.makeConstraints {
            $0.top.equalTo(mapPinIcon)
            $0.leading.equalTo(mapPinIcon.snp.trailing).offset(12)
        }

        personIcon.snp.makeConstraints {
            $0.top.equalTo(mapPinIcon.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(20)
        }

        artistsLabel.snp.makeConstraints {
            $0.top.equalTo(personIcon)
            $0.leading.equalTo(personIcon.snp.trailing).offset(11)
        }

        moneysignIcon.snp.makeConstraints {
            $0.top.equalTo(personIcon.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(20)
        }

        expenseLabel.snp.makeConstraints {
            $0.top.equalTo(moneysignIcon)
            $0.leading.equalTo(moneysignIcon.snp.trailing).offset(11)
        }

        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(moneysignIcon.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(39)
            $0.bottom.equalToSuperview().offset(-20)
        }
    }

    // 리액터에 바인딩 되는 값 주입
    func configureView(eventItem: EventItem) {
        @Dependency(\.swiftDataManager) var swiftDataManager
        let categories = swiftDataManager.fetchAllCategories()
        let categoryName = categories.first{ $0.id == eventItem.categoryId }?.name
        
        dateLabel.text = DateFormatter.toDateString(eventItem.startTime)
        categoryLabel.text = categoryName
        timelabel.text = makeTimeLabel(startTime: eventItem.startTime, endTime: eventItem.endTime)
        locationLabel.text = eventItem.location
        artistsLabel.text = makeArtistsLabel(eventItem.artists)
        expenseLabel.text = "\(eventItem.expense.formatted(.number))원"
        
    }

    // 시간 라벨 String 리턴
    private func makeTimeLabel(startTime: Date, endTime: Date) -> String {
        "시작 \(DateFormatter.toTimeString(startTime)) / 종료 \(DateFormatter.toTimeString(endTime)) 예정"
    }

    // Artists 배열 String화
    private func makeArtistsLabel(_ artists: [String]) -> String {
        return artists.joined(separator: ", ")
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
