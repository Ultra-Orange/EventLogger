//
//  HeatmapView.swift
//  EventLogger
//
//  Created by 김우성 on 9/3/25.
//

import SnapKit
import Then
import UIKit

struct HeatmapModel: Hashable {
    struct Row: Hashable {
        let yearLabel: String
        let monthCounts: [Int]
    }

    let rows: [Row]
}

// 깃허브 잔디같은 그리드 그리는 뷰
final class HeatmapView: UIView {
    enum Metrics {
        static let topPadding: CGFloat = 10
        static let headerHeight: CGFloat = 16
        static let headerBottomSpacing: CGFloat = 7
        static let bottomPadding: CGFloat = 10

        static let leftYearWidth: CGFloat = 25
        static let hSpacing: CGFloat = 8.5
        static let vSpacing: CGFloat = 8.5
        static let minCellHeight: CGFloat = 16
        static let horizontalContentInset: CGFloat = 20
        static let monthCount = 12
        static let cornerRadius: CGFloat = 4
    }

    var model: HeatmapModel? {
        didSet {
            setupYearLabels()
            setupMonthHeaderLabelsIfNeeded()
            setNeedsLayout()
            setNeedsDisplay()
        }
    }

    // 외부에서 폭을 넣어주면, 필요한 총 높이를 반환
    static func requiredHeight(for width: CGFloat, model: HeatmapModel) -> CGFloat {
        let rows = max(model.rows.count, 0)
        // 헤더(1~12)는 행이 0이어도 표시할 수 있으니 기본 높이에 포함
        let m = Metrics.self

        // 가로 셀 폭/높이 계산 (layout/draw와 동일식)
        let availableWidth = width - m.leftYearWidth - m.horizontalContentInset
        let cellW = (availableWidth - CGFloat(m.monthCount - 1) * m.hSpacing) / CGFloat(m.monthCount)
        let cellH = max(cellW, m.minCellHeight)

        // 셀 영역 높이
        let totalCellsHeight = CGFloat(rows) * cellH
        let totalVSpacing = CGFloat(max(rows - 1, 0)) * m.vSpacing

        // 최종 높이 = 상단 여백 + 헤더 높이 + 헤더-셀 간격 + 셀영역 + 행간격 + 하단여백
        return m.topPadding + m.headerHeight + m.headerBottomSpacing
            + totalCellsHeight + totalVSpacing + m.bottomPadding
    }

    private var yearLabels: [UILabel] = []
    private var monthHeaderLabels: [UILabel] = []

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let model else {
            layoutMonthHeaderLabels() // model 없어도 헤더 자체는 컬럼에 맞춰야 하니 배치
            return
        }

        let m = Metrics.self
        let rows = model.rows.count
        guard rows >= 0 else { return }

        let availableWidth = bounds.width - m.leftYearWidth - m.horizontalContentInset
        let cellW = (availableWidth - CGFloat(m.monthCount - 1) * m.hSpacing) / CGFloat(m.monthCount)
        let cellH = max(cellW, m.minCellHeight)

        // 헤더(1~12) 라벨 배치
        layoutMonthHeaderLabels()

        // 연도 라벨 배치
        for (idx, label) in yearLabels.enumerated() {
            // y 계산: 상단여백 + 헤더 + 간격 + (idx * (cellH + vSpacing))
            let startY = m.topPadding + m.headerHeight + m.headerBottomSpacing
            let y = startY + CGFloat(idx) * (cellH + m.vSpacing)
            label.frame = .init(x: 12, y: y, width: m.leftYearWidth - 6, height: cellH)
        }
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let model else { return }

        let m = Metrics.self
        let rows = model.rows.count
        guard rows > 0 else { return }

        let availableWidth = rect.width - m.leftYearWidth - m.horizontalContentInset
        let cellW = (availableWidth - CGFloat(m.monthCount - 1) * m.hSpacing) / CGFloat(m.monthCount)
        let cellH = max(cellW, m.minCellHeight)

        // 첫 셀의 시작 Y는 헤더 아래
        let startY = m.topPadding + m.headerHeight + m.headerBottomSpacing

        for (idx, row) in model.rows.enumerated() {
            let y = startY + CGFloat(idx) * (cellH + m.vSpacing)

            for month in 0 ..< m.monthCount {
                // X는 좌측 연도 라벨 영역 다음부터 시작
                let x = 12 + m.leftYearWidth + CGFloat(month) * (cellW + m.hSpacing)
                let r = CGRect(x: x, y: y, width: cellW, height: cellH)
                let c = colorForCount(row.monthCounts[safe: month] ?? 0)
                let path = UIBezierPath(roundedRect: r, cornerRadius: m.cornerRadius)
                c.setFill()
                path.fill()
            }
        }
    }

    // MARK: - Subviews setup

    private func setupYearLabels() {
        yearLabels.forEach { $0.removeFromSuperview() }
        yearLabels.removeAll()

        guard let model else { return }

        for row in model.rows {
            let label = UILabel().then {
                $0.text = row.yearLabel
                $0.textColor = .neutral50
                $0.font = .font12Regular
                $0.textAlignment = .right
                $0.adjustsFontSizeToFitWidth = true
                $0.minimumScaleFactor = 0.8
            }
            addSubview(label)
            yearLabels.append(label)
        }
    }

    private func setupMonthHeaderLabelsIfNeeded() {
        // 이미 있으면 재사용(문구는 1~12 고정)
        if monthHeaderLabels.count == Metrics.monthCount { return }

        monthHeaderLabels.forEach { $0.removeFromSuperview() }
        monthHeaderLabels.removeAll()

        for i in 1...Metrics.monthCount {
            let label = UILabel().then {
                $0.text = "\(i)"
                $0.textColor = .neutral50
                $0.font = .font13Regular
                $0.textAlignment = .center
            }
            addSubview(label)
            monthHeaderLabels.append(label)
        }
    }

    private func layoutMonthHeaderLabels() {
        // 가로 셀 폭/좌표 계산은 draw/layout과 동일해야 함
        let m = Metrics.self

        let availableWidth = bounds.width - m.leftYearWidth - m.horizontalContentInset
        guard availableWidth > 0, monthHeaderLabels.count == m.monthCount else { return }

        let cellW = (availableWidth - CGFloat(m.monthCount - 1) * m.hSpacing) / CGFloat(m.monthCount)
        let headerY = m.topPadding
        let headerH = m.headerHeight

        for month in 0 ..< m.monthCount {
            let x = 12 + m.leftYearWidth + CGFloat(month) * (cellW + m.hSpacing)
            // 헤더 라벨은 각 컬럼 셀의 중앙 정렬을 위해 cellW 폭에 맞춰 배치
            monthHeaderLabels[month].frame = CGRect(x: x, y: headerY, width: cellW, height: headerH)
        }
    }

    // MARK: - Color

    private func colorForCount(_ count: Int) -> UIColor {
        switch count {
        case 0: return .neutral700
        case 1...4: return .primary200
        case 5...8: return .primary300
        default: return .primary500
        }
    }
}

// MARK: - Safe index helper

private extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
