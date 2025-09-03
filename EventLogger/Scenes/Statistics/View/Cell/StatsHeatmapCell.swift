//
//  StatsHeatmapCell.swift
//  EventLogger
//
//  Created by 김우성 on 9/3/25.
//

import SnapKit
import UIKit
import Then

final class HeatmapCell: UICollectionViewCell {
    private let heatmapView = HeatmapView().then {
        $0.backgroundColor = .neutral800
        $0.layer.cornerRadius = 10
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(heatmapView)
        heatmapView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func configure(model: HeatmapModel) {
        heatmapView.model = model
    }
}
