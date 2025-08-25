//
//  PillSegmentedControl+Rx.swift
//  EventLogger
//
//  Created by 김우성 on 8/25/25.
//

import UIKit
import RxSwift
import RxCocoa

public extension Reactive where Base: PillSegmentedControl {

    /// VC에서 사용: segmentedControl.rx.selectedSegmentIndex
    var selectedSegmentIndex: ControlProperty<Int> {
        selectedIndex
    }

    /// 내부 구현(별칭): 선택 인덱스를 양방향 바인딩
    var selectedIndex: ControlProperty<Int> {
        let control = self.base

        // 값 스트림: .valueChanged 발생 시 현재 선택 인덱스 방출 (+ 초기값)
        let values = control.rx.controlEvent(.valueChanged)
            .map { _ in control.selectedSegmentIndex }
            .startWith(control.selectedSegmentIndex)
            .distinctUntilChanged()

        // 바인딩 시: 선택값을 설정(프로그램적으로 변경)
        let sink = Binder(control) { ctrl, newIndex in
            ctrl.selectedSegmentIndex = newIndex
        }.asObserver()

        return ControlProperty(values: values, valueSink: sink)
    }
}
