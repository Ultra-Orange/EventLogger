//
//  UIDatePicker+.swift
//  EventLogger
//
//  Created by 김우성 on 8/27/25.
//

import UIKit

extension UIDatePicker {
    func applyYearRange(minYear: Int, maxYear: Int) {
        let calendar = Calendar(identifier: .gregorian)
        var min = DateComponents(); min.year = minYear; min.month = 1; min.day = 1
        var max = DateComponents(); max.year = maxYear; max.month = 1; max.day = 1
        minimumDate = calendar.date(from: min)
        maximumDate = calendar.date(from: max)
    }
}
