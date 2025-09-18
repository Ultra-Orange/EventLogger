//
//  KeyboardToolbar.swift
//  EventLogger
//
//  Created by 김우성 on 8/28/25.
//

import UIKit

/// 키보드 상단에 툴바를 만들어 반환. "닫기" 바 버튼 제공
func makeDoneToolbar(target: Any?, action: Selector) -> UIToolbar {
    let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
    toolbar.barStyle = .default

    let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    let done = UIBarButtonItem(title: "닫기", style: .done, target: target, action: action)

    toolbar.items = [flexible, done]
    toolbar.sizeToFit()
    toolbar.backgroundColor = .secondarySystemBackground
    return toolbar
}
