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
        let yearLabel: String   // "`25" 또는 "2025" 등 넣기
        let monthCounts: [Int]  // 12개짜리 Int 배열 넣기
    }

    let rows: [Row]
}

// 깃허브 잔디같은 그리드 그리는 뷰
// HeatmapView.swift

final class HeatmapView: UIView {
    // 레이아웃 상수 한 곳에서 관리
    struct Metrics {
        static let topPadding: CGFloat = 12
        static let bottomPadding: CGFloat = 12
        static let leftYearWidth: CGFloat = 36
        static let hSpacing: CGFloat = 6    // 월 칸 사이 간격 (12개)
        static let vSpacing: CGFloat = 6    // 행 간격
        static let minCellHeight: CGFloat = 18
        static let horizontalContentInset: CGFloat = 24 // 좌우 총 여백(= 12 + 12)
        static let monthCount = 12
        static let cornerRadius: CGFloat = 4
    }

    var model: HeatmapModel? {
        didSet {
            setupYearLabels()
            setNeedsLayout()
            setNeedsDisplay()
        }
    }

    // 외부에서 폭을 넣어주면, 필요한 총 높이를 반환
    static func requiredHeight(for width: CGFloat, model: HeatmapModel) -> CGFloat {
        let rows = max(model.rows.count, 0)
        guard rows > 0 else {
            return Metrics.topPadding + Metrics.bottomPadding + Metrics.minCellHeight
        }

        // HeatmapView 내부에서 쓰는 계산식과 동일하게 맞추기
        let availableWidth = width - Metrics.leftYearWidth - Metrics.horizontalContentInset
        let cellW = (availableWidth - CGFloat(Metrics.monthCount - 1) * Metrics.hSpacing) / CGFloat(Metrics.monthCount)
        let cellH = max(cellW, Metrics.minCellHeight)

        let totalCellsHeight = CGFloat(rows) * cellH
        let totalVSpacing = CGFloat(max(rows - 1, 0)) * Metrics.vSpacing

        return Metrics.topPadding + totalCellsHeight + totalVSpacing + Metrics.bottomPadding
    }

    private var yearLabels: [UILabel] = []

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let model else { return }

        let m = Metrics.self

        let rows = model.rows.count
        guard rows > 0 else { return }

        let availableWidth = bounds.width - m.leftYearWidth - m.horizontalContentInset
        let cellW = (availableWidth - CGFloat(m.monthCount - 1) * m.hSpacing) / CGFloat(m.monthCount)
        let cellH = max(cellW, m.minCellHeight)

        for (idx, label) in yearLabels.enumerated() {
            let y = m.topPadding + CGFloat(idx) * (cellH + m.vSpacing)
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

        for (idx, row) in model.rows.enumerated() {
            let y = m.topPadding + CGFloat(idx) * (cellH + m.vSpacing)

            for month in 0 ..< m.monthCount {
                let x = 12 + m.leftYearWidth + CGFloat(month) * (cellW + m.hSpacing)
                let r = CGRect(x: x, y: y, width: cellW, height: cellH)
                let c = colorForCount(row.monthCounts[month])
                let path = UIBezierPath(roundedRect: r, cornerRadius: m.cornerRadius)
                c.setFill()
                path.fill()
            }
        }
    }

    private func setupYearLabels() {
        yearLabels.forEach { $0.removeFromSuperview() }
        yearLabels.removeAll()

        guard let model else { return }

        for row in model.rows {
            let label = UILabel().then {
                $0.text = row.yearLabel
                $0.textColor = .neutral200
                $0.font = .systemFont(ofSize: 13, weight: .medium)
            }
            addSubview(label)
            yearLabels.append(label)
        }
    }

    private func colorForCount(_ count: Int) -> UIColor {
        switch count {
        case 0:     return .neutral700
        case 1...4: return .primary200
        case 5...8: return .primary300
        default:    return .primary500
        }
    }
}
