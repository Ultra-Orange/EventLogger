//
//  StatBoxView.swift
//  EventLogger
//
//  Created by 김우성 on 9/3/25.
//

import UIKit
import SnapKit
import Then

final class StatBoxView: UIView {
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    
    private let stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.alignment = .center
    }
    
    init(title: String) {
        super.init(frame: .zero)
        
        titleLabel.text = title
        titleLabel.font = .font17Regular
        titleLabel.textColor = .neutral50
        
        valueLabel.font = .font28Bold
        valueLabel.textColor = .neutral50
        
        addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(valueLabel)
        
        stackView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(8)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func setValue(_ text: String) { valueLabel.text = text }
}
