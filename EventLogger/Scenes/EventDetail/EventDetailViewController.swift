//
//  EventDetailViewController.swift
//  EventLogger
//
//  Created by 김우성 on 8/20/25.
//

import UIKit

class EventDetailViewController: BaseViewController<EventDetailReactor> {
    override func setupUI() {
        view.backgroundColor = .systemOrange
    }

    override func bind(reactor: EventDetailReactor) {}
}
