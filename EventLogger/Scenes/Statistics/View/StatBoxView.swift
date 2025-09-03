//
//  StatBoxView.swift
//  EventLogger
//
//  Created by 김우성 on 9/3/25.
//

import SnapKit
import Then
import UIKit

final class StatBoxView: UIView {
    private let stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.alignment = .center
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .font17Regular
        $0.textColor = .neutral50
    }

    private let valueLabel = UILabel().then {
        $0.font = .font28Bold
        $0.textColor = .neutral50
    }
    
    init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        
        addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(valueLabel)
        
        stackView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(8)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
    
    func setValue(_ text: String) {
        valueLabel.text = text
    }
}
