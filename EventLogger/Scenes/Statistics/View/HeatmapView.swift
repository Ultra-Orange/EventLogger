//
//  HeatmapView.swift
//  EventLogger
//
//  Created by 김우성 on 9/3/25.
//

import UIKit
import SnapKit

// Heatmap: rows = years(desc), columns = 1~12
struct HeatmapModel: Hashable {
    struct Row: Hashable {
        let yearLabel: String   // `25 처럼 포맷 포함 또는 단순 "2025"
        let monthCounts: [Int]  // length 12
    }
    let rows: [Row]
}

// 잔디같은 그리드 그리는 뷰
final class HeatmapView: UIView {
    var model: HeatmapModel? {
        didSet {
            setNeedsLayout()
            setNeedsDisplay()
        }
    }

    private let legend = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(legend)

        legend.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(12)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(160)
            $0.height.equalTo(12)
        }
        buildLegend()
    }
    required init?(coder: NSCoder) { fatalError() }
    
    private func buildLegend() {
        let colors: [UIColor] = [
            UIColor.neutral600, // 0회
            UIColor.primary700, // 1~4
            UIColor.primary600, // 5~8
            UIColor.primary400  // 9+
        ]
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 6
        legend.addSubview(stack)
        stack.snp.makeConstraints { $0.edges.equalToSuperview() }
        for c in colors {
            let v = UIView()
            v.backgroundColor = c
            v.layer.cornerRadius = 2
            stack.addArrangedSubview(v)
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let model else { return }
        
        let topPadding: CGFloat = 12   // 헤더가 있으니 여유만
        let leftYearWidth: CGFloat = 36
        let hSpacing: CGFloat = 6
        let vSpacing: CGFloat = 6
        
        let rows = model.rows.count
        guard rows > 0 else { return }
        
        // 셀 사이즈 계산 (12개 월 고정)
        let availableWidth = rect.width - leftYearWidth - 24  // 좌측 연도 + 패딩
        let cellW = (availableWidth - 11 * hSpacing) / 12.0
        let cellH = max(cellW, 18)
        
        // 연도 라벨
        for (idx, row) in model.rows.enumerated() {
            let y = topPadding + CGFloat(idx) * (cellH + vSpacing)
            let label = UILabel(frame: .init(x: 12, y: y, width: leftYearWidth - 6, height: cellH))
            label.text = row.yearLabel
            label.textColor = .neutral200
            label.font = .systemFont(ofSize: 13, weight: .medium)
            addSubview(label)
            
            for month in 0..<12 {
                let x = 12 + leftYearWidth + CGFloat(month) * (cellW + hSpacing)
                let r = CGRect(x: x, y: y, width: cellW, height: cellH)
                let c = colorForCount(row.monthCounts[month])
                let path = UIBezierPath(roundedRect: r, cornerRadius: 4)
                c.setFill()
                path.fill()
            }
        }
    }
    
    private func colorForCount(_ count: Int) -> UIColor {
        switch count {
        case 0: return .neutral600
        case 1...4: return .primary700
        case 5...8: return .primary600
        default: return .primary400
        }
    }
}
