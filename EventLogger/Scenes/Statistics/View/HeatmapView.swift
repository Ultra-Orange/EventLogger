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
final class HeatmapView: UIView {
    var model: HeatmapModel? {
        didSet {
            setupYearLabels()
            setNeedsLayout()
            setNeedsDisplay()
        }
    }
    
    private var yearLabels: [UILabel] = []
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let model else { return }
        
        let topPadding: CGFloat = 12
        let leftYearWidth: CGFloat = 36
        let hSpacing: CGFloat = 6
        let vSpacing: CGFloat = 6
        
        let rows = model.rows.count
        guard rows > 0 else { return }
        
        let availableWidth = bounds.width - leftYearWidth - 24
        let cellW = (availableWidth - 11 * hSpacing) / 12.0
        let cellH = max(cellW, 18)
        
        for (idx, label) in yearLabels.enumerated() {
            let y = topPadding + CGFloat(idx) * (cellH + vSpacing)
            label.frame = .init(x: 12, y: y, width: leftYearWidth - 6, height: cellH)
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let model else { return }
        
        let topPadding: CGFloat = 12
        let leftYearWidth: CGFloat = 36
        let hSpacing: CGFloat = 6
        let vSpacing: CGFloat = 6
        
        let rows = model.rows.count
        guard rows > 0 else { return }
        
        let availableWidth = rect.width - leftYearWidth - 24
        let cellW = (availableWidth - 11 * hSpacing) / 12.0
        let cellH = max(cellW, 18)
        
        for (idx, row) in model.rows.enumerated() {
            let y = topPadding + CGFloat(idx) * (cellH + vSpacing)
            
            for month in 0 ..< 12 {
                let x = 12 + leftYearWidth + CGFloat(month) * (cellW + hSpacing)
                let r = CGRect(x: x, y: y, width: cellW, height: cellH)
                let c = colorForCount(row.monthCounts[month])
                let path = UIBezierPath(roundedRect: r, cornerRadius: 4)
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
        case 0: return .neutral700
        case 1...4: return .primary200
        case 5...8: return .primary300
        default: return .primary500
        }
    }
}
