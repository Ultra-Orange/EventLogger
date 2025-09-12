//
//  InfoItemView.swift
//  EventLogger
//
//  Created by 김우성 on 9/5/25.
//

import Dependencies
import SnapKit
import Then
import UIKit

// 정보 카드 부분 뷰
class InfoItemView: UIView {
    private let infoCardView = UIView().then {
        $0.backgroundColor = .systemGray6
        $0.layer.cornerRadius = 12
    }

    private let infoVStack = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 16
        $0.alignment = .leading
        $0.distribution = .fill
    }

    let addCalendarButton = UIButton(configuration: .defaultButton).then {
        $0.configuration?.title = "캘린더에 추가"
        $0.configuration?.baseBackgroundColor = .primary500
    }

    let findDirectionsButton = UIButton(configuration: .defaultColorReversed).then {
        $0.configuration?.title = "길 찾기"
        $0.configuration?.baseForegroundColor = .primary500
        $0.configuration?.background.backgroundColor = .clear
        $0.configuration?.background.strokeColor = .primary500
        $0.configuration?.background.strokeWidth = 1
    }

    private let buttonStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 16
        $0.alignment = .fill
        $0.distribution = .fillEqually
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(infoCardView)
        infoCardView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        infoCardView.addSubview(infoVStack)
        infoVStack.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(16)
        }

        infoCardView.addSubview(buttonStackView)
        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(infoVStack.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(42)
            $0.bottom.equalToSuperview().inset(16)
        }
        buttonStackView.addArrangedSubview(addCalendarButton)
        buttonStackView.addArrangedSubview(findDirectionsButton)
    }

    private func makeInfoHStack(icon: String, value: String) -> UIStackView {
        let iconImageView = UIImageView(image: UIImage(systemName: icon, withConfiguration: .font17Regular)).then {
            $0.tintColor = .primary500

            // SF Symbol의 가로폭이 달라지는 문제를 해결하기 위해 명시적으로 크기 고정
            $0.snp.makeConstraints { make in
                make.width.equalTo(20)
                make.height.equalTo(20)
            }
        }

        let titleLabel = UILabel().then {
            $0.text = value
            $0.font = .font17Regular
            $0.numberOfLines = 0
        }

        let hStack = UIStackView(arrangedSubviews: [iconImageView, titleLabel]).then {
            $0.axis = .horizontal
            $0.spacing = 10
            $0.alignment = .top
        }
        return hStack
    }

    func configureView(eventItem: EventItem) {
        @Dependency(\.swiftDataManager) var swiftDataManager
        let categories = swiftDataManager.fetchAllCategories()

        let date = DateFormatter.toDateString(eventItem.startTime)
        let categoryName = categories.first { $0.id == eventItem.categoryId }?.name ?? ""
        let time = "시작 \(DateFormatter.toTimeString(eventItem.startTime)) / 종료 \(DateFormatter.toTimeString(eventItem.endTime)) 예정"
        let location = eventItem.location ?? ""
        let artists = eventItem.artists.joined(separator: ", ")
        let expense = "\(eventItem.expense.formatted(.number))원"

        infoVStack.addArrangedSubview(makeInfoHStack(icon: "calendar", value: date))
        infoVStack.addArrangedSubview(makeInfoHStack(icon: "tag", value: categoryName))
        infoVStack.addArrangedSubview(makeInfoHStack(icon: "clock", value: time))
        infoVStack.addArrangedSubview(makeInfoHStack(icon: "mappin.and.ellipse", value: location))
        infoVStack.addArrangedSubview(makeInfoHStack(icon: "person", value: artists))
        infoVStack.addArrangedSubview(makeInfoHStack(icon: "wonsign.circle", value: expense))
    }
}
