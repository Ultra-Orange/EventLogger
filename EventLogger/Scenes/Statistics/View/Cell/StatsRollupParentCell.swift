//
//  StatsRollupParentCell.swift
//  EventLogger
//
//  Created by 김우성 on 9/3/25.
//

import UIKit
import SnapKit
import Then

final class StatsRollupParentCell: UICollectionViewListCell {
    private let horizontalStack = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.spacing = 8
    }
    
    private let dotView = UIView().then {
        $0.layer.cornerRadius = 8
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .font17Regular
        $0.textColor = .neutral50
    }
    
    private let valueLabel = UILabel().then {
        $0.font = .font17Regular
        $0.textColor = .neutral50
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    private let chevronImageView = UIImageView().then {
        let cfg = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        $0.image = UIImage(systemName: "chevron.down", withConfiguration: cfg)
        $0.tintColor = .neutral300
        $0.setContentHuggingPriority(.required, for: .horizontal)
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        // 회전 시 가장자리 aliasing 줄이기(선택)
        $0.layer.allowsEdgeAntialiasing = true
    }
    
    private var isExpanded: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        backgroundView = UIView()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupUI() {
        var config = defaultContentConfiguration()
        config.text = nil
        contentConfiguration = config
        accessories = []
        
        dotView.snp.makeConstraints {
            $0.size.equalTo(16)
        }
        
        horizontalStack.addArrangedSubview(dotView)
        horizontalStack.addArrangedSubview(titleLabel)
        horizontalStack.addArrangedSubview(UIView())
        horizontalStack.addArrangedSubview(valueLabel)
        horizontalStack.addArrangedSubview(chevronImageView)
        
        contentView.addSubview(horizontalStack)
        horizontalStack.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(13)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
    }
    
    func configure(title: String, valueText: String, leftDotColor: UIColor?) {
        titleLabel.text = title
        valueLabel.text = valueText
        
        if let color = leftDotColor {
            dotView.isHidden = false
            dotView.backgroundColor = color
        } else {
            dotView.isHidden = true
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // 재사용 시 안전하게 초기화(실제 상태는 setChevron에서 다시 설정됨)
        chevronImageView.transform = .identity
        isExpanded = false
    }
    
    /// 회전 애니메이션 기반 전환
    func setChevron(expanded: Bool, animated: Bool) {
        isExpanded = expanded
        let targetAngle: CGFloat = expanded ? .pi : 0
        
        let apply: () -> Void = { [weak self] in
            self?.chevronImageView.transform = CGAffineTransform(rotationAngle: targetAngle)
        }
        
        guard animated, !UIAccessibility.isReduceMotionEnabled else {
            apply()
            return
        }
        
        UIView.animate(
            withDuration: 0.35,
            delay: 0,
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: 0.4,
            options: [.beginFromCurrentState, .allowUserInteraction],
            animations: apply,
            completion: nil
        )
    }
    
}

#Preview {
    let cell = StatsRollupParentCell()
    cell.configure(title: "페스티벌", valueText: "1회", leftDotColor: .appBlue)
    return cell
}
