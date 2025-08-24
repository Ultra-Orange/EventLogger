//
//  EventListViewController.swift
//  EventLogger
//
//  Created by 김우성 on 8/20/25.
//

import ReactorKit
import RxSwift
import UIKit

final class EventListViewController: BaseViewController<EventListReactor> {
    
    private let segmentedControl = PillSegmentedControl(items: ["전체", "참여예정", "참여완료"]).then {
        // 디자인 커스터마이즈 (기존 유지)
        $0.font = UIFont.preferredFont(forTextStyle: .body)
        $0.capsuleBackgroundColor = .black
        $0.capsuleBorderColor = .white.withAlphaComponent(0.5)
        $0.capsuleBorderWidth = 1
        $0.normalTextColor = .white
        $0.selectedTextColor = .white
        $0.borderColor = .white.withAlphaComponent(0.5)
        $0.borderWidth = 1
        $0.segmentSpacing = 6
        $0.contentInsets = .init(top: 3, leading: 3, bottom: 3, trailing: 3 )
        // UISegmentedControl과 동일: 선택 인덱스 설정
        $0.selectedSegmentIndex = 0
        // 타깃/액션: self를 타깃으로
        $0.addTarget(nil, action: #selector(handleValueChanged), for: .valueChanged)
    }
    
    override func setupUI() {
        self.title = "Event Logger"
        view.backgroundColor = .black
        
        view.addSubview(segmentedControl)
        segmentedControl.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(50)
        }
    }
    
    override func bind(reactor: EventListReactor) {
        rx.viewWillAppear.map { _ in .reloadEventItems }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    @objc private func handleValueChanged() {
        let index = segmentedControl.selectedSegmentIndex
        let title = segmentedControl.titleForSegment(at: index) ?? "알 수 없음"
        print("선택됨: index=\(index), title=\(title)")
    }
}

#Preview {
    EventListViewController()
}
