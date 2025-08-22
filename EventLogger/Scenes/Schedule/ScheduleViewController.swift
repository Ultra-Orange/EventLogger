//
//  ScheduleViewController.swift
//  EventLogger
//
//  Created by Yoon on 8/22/25.
//

import UIKit
import ReactorKit
import RxCocoa
import RxSwift
import SnapKit
import SwiftUI
import Then

class ScheduleViewController: BaseViewController<ScheduleReactor> {
    
    override func setupUI() {
        view.backgroundColor = .systemBackground
        print("ScheduleViewController")
    }
    
    override func bind(reactor: ScheduleReactor) {
        title = reactor.currentState.navTitle
        print(reactor.currentState.navTitle)
        let item = reactor.currentState.eventItem
        guard let item else { return }
        print(item.id)
        print(item.artists)
    }
}
