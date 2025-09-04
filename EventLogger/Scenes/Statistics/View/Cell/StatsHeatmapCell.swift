//
//  StatsHeatmapCell.swift
//  EventLogger
//
//  Created by 김우성 on 9/3/25.
//

import SnapKit
import UIKit
import Then

final class StatsHeatmapCell: UICollectionViewCell {
    private let heatmapView = HeatmapView().then {
        $0.backgroundColor = .neutral800
        $0.layer.cornerRadius = 10
        $0.layer.cornerCurve = .continuous
        $0.clipsToBounds = true
    }
    
    private var currentModel: HeatmapModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupUI() {
        contentView.addSubview(heatmapView)
        heatmapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 셀 자가사이징 안정화
        contentView.setContentCompressionResistancePriority(.required, for: .vertical)
        contentView.setContentHuggingPriority(.required, for: .vertical)
    }
    
    func configure(model: HeatmapModel) {
        currentModel = model
        heatmapView.model = model
        // 모델이 바뀌면 레이아웃 재계산 트리거
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    // 주어진 폭으로 필요한 높이를 직접 계산해서 반환
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        guard let model = currentModel else { return super.preferredLayoutAttributesFitting(layoutAttributes) }
        
        let attrs = layoutAttributes.copy() as! UICollectionViewLayoutAttributes
        let targetWidth = attrs.size.width
        
        // HeatmapView의 계산식 활용
        let neededHeight = HeatmapView.requiredHeight(for: targetWidth, model: model)
        
        // 카드 모서리 그림자/보정 등을 고려해 약간의 여유를 줘도 OK
        attrs.size.height = ceil(neededHeight)
        
        return attrs
    }
}
