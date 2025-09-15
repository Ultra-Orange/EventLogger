//
//  KRWFormatter.swift
//  EventLogger
//
//  Created by 김우성 on 9/12/25.
//

import Foundation

final class KRWFormatter {
    static let shared = KRWFormatter()
    private let nf: NumberFormatter
    private init() {
        nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.groupingSeparator = ","
        nf.maximumFractionDigits = 0
    }

    func string(_ value: Double) -> String {
        let v = Int(value.rounded())
        return (nf.string(from: NSNumber(value: v)) ?? "\(v)") + " 원"
    }
}
