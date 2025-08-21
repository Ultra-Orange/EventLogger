//
//  EventListViewController.swift
//  EventLogger
//
//  Created by 김우성 on 8/20/25.
//

import ReactorKit
import RxSwift
import UIKit

class EventListViewController: BaseViewController<EventListReactor> {
    override func setupUI() {
        view.backgroundColor = .systemOrange
    }

    override func bind(reactor: EventListReactor) {
        rx.viewWillAppear.map { _ in .reloadEventItems }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
}
