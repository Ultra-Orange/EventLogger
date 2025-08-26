//
//  LocationSearchViewController.swift
//  EventLogger
//
//  Created by Yoon on 8/26/25.
//

// LocationSearchViewController.swift
import UIKit
import SnapKit
import Then

class LocationSearchViewController: UIViewController {
    // MARK: UI Components
    private let titleLabel = UILabel().then {
        $0.text = "여기가 바텀시트 테스트 화면"
        $0.textAlignment = .center
        $0.font = .font16Regular
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupUI()
    }

    private func setupUI() {
        view.addSubview(titleLabel)

        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        // 바텀시트 스타일 적용
        if let sheet = sheetPresentationController {
            sheet.detents = [.large()] // 드래그 높이
            sheet.prefersGrabberVisible = true    // 위 손잡이 표시
        }
    }
}
