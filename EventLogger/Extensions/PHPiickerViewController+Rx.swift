//
//  PHPiickerViewController+Rx.swift
//  EventLogger
//
//  Created by Yoon on 9/12/25.
//
import PhotosUI
import RxCocoa
import RxSwift

extension Reactive where Base: PHPickerViewController {
    var delegate: RxPHPickerViewControllerDelegateProxy {
        return RxPHPickerViewControllerDelegateProxy.proxy(for: base)
    }

    func setDelegate(_ delegate: PHPickerViewControllerDelegate) -> Disposable {
        return RxPHPickerViewControllerDelegateProxy.installForwardDelegate(delegate, retainDelegate: false, onProxyForObject: base)
    }

    var selectedImages: ControlEvent<[UIImage]> {
        let source = delegate.didFinishPickingRelay
            .map {
                $0.map { $0.rx.loadImage().catchAndReturn(nil).compactMap { $0 } }
            }
            .flatMap { Observable.zip($0) }
        return ControlEvent(events: source.take(until: base.rx.deallocated))
    }
}

class RxPHPickerViewControllerDelegateProxy: DelegateProxy<PHPickerViewController, PHPickerViewControllerDelegate>, DelegateProxyType, PHPickerViewControllerDelegate {
    let didFinishPickingRelay = PublishSubject<[PHPickerResult]>()

    static func registerKnownImplementations() {
        register {
            RxPHPickerViewControllerDelegateProxy(parentObject: $0, delegateProxy: RxPHPickerViewControllerDelegateProxy.self)
        }
    }

    static func currentDelegate(for object: PHPickerViewController) -> PHPickerViewControllerDelegate? {
        return object.delegate
    }

    static func setCurrentDelegate(_ delegate: PHPickerViewControllerDelegate?, to object: PHPickerViewController) {
        object.delegate = delegate
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        didFinishPickingRelay.on(.next(results))
        picker.dismiss(animated: true)
    }

    deinit {
        didFinishPickingRelay.on(.completed)
    }
}

extension PHPickerResult: @retroactive ReactiveCompatible {}

extension Reactive where Base == PHPickerResult {
    func loadImage() -> Observable<UIImage?> {
        return Observable.create { [base] observer in
            if base.itemProvider.canLoadObject(ofClass: UIImage.self) {
                base.itemProvider.loadObject(ofClass: UIImage.self) { item, error in
                    if let image = item as? UIImage {
                        observer.on(.next(image))
                    } else if let error {
                        observer.on(.error(error))
                    }
                    observer.on(.completed)
                }
            } else {
                observer.on(.next(nil))
                observer.on(.completed)
            }
            return Disposables.create()
        }
    }
}
