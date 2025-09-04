//
//  HeatmapFooterView.swift
//  EventLogger
//
//  Created by 김우성 on 9/3/25.
//
//
import SnapKit
import UIKit
import Then

final class HeatmapFooterView: UICollectionReusableView {
    static let elementKind = "HeatmapFooterElementKind"

    private let container = UIView() // Heatmap에서만 사용

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(container)

        container.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        buildLegend()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    func configure(title: String, showLegend: Bool) {
        
    }

    private func buildLegend() {
        let stack = UIStackView().then {
            $0.axis = .horizontal
            $0.alignment = .fill
            $0.distribution = .fill
            $0.spacing = 12
        }
        
        container.addSubview(stack)
        stack.snp.makeConstraints {
            $0.leading.equalToSuperview()
        }
        
        
        let colorsAndTitle: [(UIColor, String)] = [
            (UIColor.neutral700, "0회"),
            (UIColor.primary200, "1~4회"),
            (UIColor.primary300, "5~8회"),
            (UIColor.primary500, "9회 이상")
        ]
        
        for color in colorsAndTitle {
            let colorStack = UIStackView().then {
                $0.axis = .horizontal
                $0.alignment = .center
                $0.distribution = .fill
                $0.spacing = 4
            }
            
            let colorTile = UIView().then {
                $0.backgroundColor = color.0
                $0.layer.cornerRadius = 3
            }
            
            let label = UILabel().then {
                $0.text = color.1
                $0.font = .font11Regular
                $0.textColor = .neutral50
            }
            
            colorTile.snp.makeConstraints {
                $0.size.equalTo(12)
            }
            
            colorStack.addArrangedSubview(colorTile)
            colorStack.addArrangedSubview(label)
            
            stack.addArrangedSubview(colorStack)
            
            
        }
    }
}
