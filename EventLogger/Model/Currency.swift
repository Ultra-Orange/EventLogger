//
//  Currency.swift
//  EventLogger
//
//  Created by Yoon on 8/21/25.
//

enum Currency: String {
    // 향후 확장성을 위해 유지
    case KRW

    var description: String {
        return rawValue
    }
}
