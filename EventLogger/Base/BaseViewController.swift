
import UIKit

import ReactorKit
import RxSwift

// 모든 VC의 부모
class BaseViewController<R: Reactor>: UIViewController, View {
    // 모든 VC에 들어가는 것들
    var disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backButtonDisplayMode = .minimal
        setupUI()
    }

    func setupUI() {
        // override에서 UI설정
    }

    func bind(reactor: R) {
        // 각 VC에서 상태 바인딩 시 override
    }
}
