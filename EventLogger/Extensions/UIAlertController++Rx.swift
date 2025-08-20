import UIKit

import RxCocoa
import RxSwift

// MARK: - Reactive (UIAlertController)

extension Reactive where Base: UIAlertController {
    static func alert<T>(
        on viewController: UIViewController?,
        title: String? = nil,
        message: String? = nil,
        actions: [RxAlertAction<T>]
    ) -> ControlEvent<T> {
        return _rxAlertController(on: viewController, title: title, message: message, style: .alert, actions: actions)
    }

    static func actionSheet<T>(
        on viewController: UIViewController?,
        title: String? = nil,
        message: String? = nil,
        actions: [RxAlertAction<T>]
    ) -> ControlEvent<T> {
        return _rxAlertController(on: viewController, title: title, message: message, style: .actionSheet, actions: actions)
    }

    private static func _rxAlertController<T>(
        on viewController: UIViewController?,
        title: String? = nil,
        message: String? = nil,
        style: UIAlertController.Style,
        actions: [RxAlertAction<T>]
    ) -> ControlEvent<T> {
        let source = Maybe<Event<T>>
            .create { [weak viewController] observer in
                guard let viewController = viewController else {
                    observer(.completed)
                    return Disposables.create()
                }
                let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
                for action in actions {
                    let alertAction = UIAlertAction(title: action.title, style: action.style) { _ in
                        observer(.success(action.event()))
                    }
                    alertController.addAction(alertAction)
                }
                viewController.present(alertController, animated: true)

                return Disposables.create {
                    alertController.dismiss(animated: true)
                }
            }
            .asObservable()
            .flatMap { event in
                Observable<T>.create { observer in
                    switch event {
                    case .next:
                        observer.on(event)
                        observer.on(.completed)
                    case .completed, .error:
                        observer.on(.completed)
                    }
                    return Disposables.create()
                }
            }
        return ControlEvent(events: source)
    }
}

// MARK: - RxAlertAction<T>

struct RxAlertAction<T> {
    let title: String
    let style: UIAlertAction.Style
    let event: () -> Event<T>

    static func action(_ title: String) -> RxAlertAction<T> {
        return RxAlertAction(title: title, style: .default, event: { .completed })
    }

    static func action(_ title: String, payload: T) -> RxAlertAction<T> {
        return RxAlertAction(title: title, style: .default, event: { .next(payload) })
    }

    static func cancel(_ title: String) -> RxAlertAction<T> {
        return RxAlertAction(title: title, style: .cancel, event: { .completed })
    }

    static func cancel(_ title: String, payload: T) -> RxAlertAction<T> {
        return RxAlertAction(title: title, style: .cancel, event: { .next(payload) })
    }

    static func destructive(_ title: String) -> RxAlertAction<T> {
        return RxAlertAction(title: title, style: .destructive, event: { .completed })
    }

    static func destructive(_ title: String, payload: T) -> RxAlertAction<T> {
        return RxAlertAction(title: title, style: .destructive, event: { .next(payload) })
    }
}

/**
 clearFavoriteButton.rx.tap
     .withUnretained(self)
     .flatMap { `self`, _ in
         UIAlertController.rx.alert(on: self, title: "전체 삭제", message: "담은 책을 모두 삭제하시겠습니까?", actions: [
             .cancel("취소"),
             .destructive("삭제", payload: .clearFavoriteBooks),
         ])
     }
     .bind(to: reactor.action)
     .disposed(by: disposeBag)

 */
