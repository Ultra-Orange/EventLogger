
import Foundation
import ReactorKit
import RxFlow
import RxRelay
import RxSwift
import SwiftData

protocol BaseReactor: Reactor, Stepper {}

// 메모리 주소에서 쓸 key
private var __stepsRelay: UInt8 = 0

extension BaseReactor {
    // 저장할 수 있는 공간을 할당할 수 없기 때문에 런타임에 AssociatedObject를 사용해 추가할 공간을 할당
    var steps: PublishRelay<Step> {
        if let object = objc_getAssociatedObject(self, &__stepsRelay) as? PublishRelay<Step> {
            return object
        }
        let newObject = PublishRelay<Step>()
        objc_setAssociatedObject(self, &__stepsRelay, newObject, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return newObject
    }

    // state를 변경하는 행위는 이 transform을 타게되서 .observe를 일일이 넣어주지 않아도 된다.
    func transform(state: Observable<State>) -> Observable<State> {
        return state.observe(on: MainScheduler.instance)
    }
}
