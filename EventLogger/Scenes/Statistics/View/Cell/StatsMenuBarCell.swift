//
//  StatsMenuBarCell.swift
//  EventLogger
//
//  Created by 김우성 on 9/3/25.
//

import SnapKit
import Then
import UIKit

enum Scope: Int {
    case year // 연도별
    case month // 월별
    case all // 전체
}

// 1) UIMenu 버튼 섹션 셀
/// - 이 셀은 "연도/월 선택 UI"만 담당.
/// - 실제 상태 변경은 VC → Reactor로 흘러감(onYearPicked/onMonthPicked 클로저)
final class StatsMenuBarCell: UICollectionViewCell {
    private let container = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 12
    }

    private let yearButton = UIButton(type: .system).then {
        $0.backgroundColor = .neutral800
        $0.layer.cornerRadius = 13
    }

    private let monthButton = UIButton(type: .system).then {
        $0.backgroundColor = .neutral800
        $0.layer.cornerRadius = 13
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 12)
        let symbolImage = UIImage(systemName: "chevron.up.chevron.down", withConfiguration: symbolConfiguration)

        var configuration = UIButton.Configuration.plain()
        configuration.image = symbolImage
        configuration.imagePlacement = .trailing
        configuration.imagePadding = 4
        configuration.attributedTitle = AttributedString("연도", attributes: AttributeContainer([.font: UIFont.font13Regular]))

        yearButton.configuration = configuration
        monthButton.configuration = configuration

        contentView.addSubview(container)
        container.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        container.addArrangedSubview(UIView())
        container.addArrangedSubview(yearButton)
        container.addArrangedSubview(monthButton)
    }

    func configure(
        scope: Scope,
        yearProvider: () -> [String],
        selectedYear: Int?,
        selectedMonth: Int?,
        isMonthEnabled: (Int) -> Bool = { _ in true },
        onYearPicked: @escaping (Int) -> Void,
        onMonthPicked: @escaping (Int) -> Void,
    ) {
        let years = yearProvider()
        let yearActions = years.compactMap { Int($0) }.map { y in
            UIAction(title: "\(y)년") { _ in onYearPicked(y) }
        }
        let yearToDisplay = selectedYear ?? (Int(years.first ?? "") ?? 0)

        yearButton.configuration?.attributedTitle = AttributedString(
            "\(yearToDisplay)년",
            attributes: AttributeContainer([.font: UIFont.font13Regular])
        )
        yearButton.menu = UIMenu(children: yearActions)
        yearButton.showsMenuAsPrimaryAction = true

        switch scope {
        case .year: // 월 버튼 숨김, 연도만
            monthButton.isHidden = true

        case .month:
            monthButton.isHidden = false

            let monthTitle: String = {
                if let m = selectedMonth { return "\(m)월" }
                else { return "월 선택" }
            }()
            monthButton.configuration?.attributedTitle = AttributedString(
                monthTitle,
                attributes: AttributeContainer([.font: UIFont.font13Regular])
            )

            let months = (1 ... 12).map { month -> UIAction in
                let action = UIAction(title: "\(month)월") { _ in onMonthPicked(month) }
                if !isMonthEnabled(month) {
                    action.attributes.insert(.disabled) // 회색 처리 & 탭 비활성화
                }
                // 선택 상태 표시(optional)
                if selectedMonth == month {
                    action.state = .on
                }
                return action
            }

            monthButton.menu = UIMenu(children: months)
            monthButton.showsMenuAsPrimaryAction = true

        case .all:
            // 이 셀 자체가 안 보이는 섹션이므로 신경 X
            monthButton.isHidden = true
        }
    }
}
