//
//  SplashViewController.swift
//  EventLogger
//
//  Created by Yoon on 9/17/25.
//

import UIKit
import Then
import SnapKit
import RxFlow
import RxRelay

final class SplashViewController: UIViewController, Stepper {
    let steps = PublishRelay<any Step>()

    let splashLogo = UIImageView(image: .splashLogo).then{
        $0.tintColor = UIColor(red: 195/255, green: 81/255, blue: 4/255, alpha: 1)
    }

    let splashBlur = UIImageView(image: .splashBlur).then{
        $0.alpha = 0
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .appBackground
        view.addSubview(splashBlur)
        view.addSubview(splashLogo)

        splashBlur.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        splashLogo.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let blurAnimator = UIViewPropertyAnimator(duration: 2.0, curve: .linear) {
            self.splashBlur.alpha = 1
        }
        
        blurAnimator.startAnimation()

        let firstLogoAnimator = UIViewPropertyAnimator(duration: 1.0, curve: .linear) {
            self.splashLogo.tintColor = UIColor(red: 245/255, green: 101/255, blue: 5/255, alpha: 1)
        }

        firstLogoAnimator.startAnimation()

        let secondLogoAnimator = UIViewPropertyAnimator(duration: 1.0, curve: .linear) {
            self.splashLogo.tintColor = UIColor(red: 251/255, green: 130/255, blue: 49/255, alpha: 1)
        }

        secondLogoAnimator.addCompletion { [steps] _ in
            steps.accept(AppStep.eventList)
        }

        secondLogoAnimator.startAnimation(afterDelay: 1.0)

    }
}
