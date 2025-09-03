//
//  StatsHeatmapCell.swift
//  EventLogger
//
//  Created by 김우성 on 9/3/25.
//

import UIKit
import SnapKit

// 2) Heatmap 셀
final class HeatmapCell: UICollectionViewCell {
    private let heatmapView = HeatmapView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(heatmapView)
        heatmapView.snp.makeConstraints { $0.edges.equalToSuperview() }
        heatmapView.layer.cornerRadius = 12
        heatmapView.backgroundColor = .neutral700
    }
    required init?(coder: NSCoder) { fatalError() }
    func configure(model: HeatmapModel) {
        heatmapView.model = model
    }
}
