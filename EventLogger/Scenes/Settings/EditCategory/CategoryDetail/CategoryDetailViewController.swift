//
//  CategoryDetailViewController.swift
//  EventLogger
//
//  Created by Yoon on 9/2/25.
//
import UIKit

import ReactorKit
import RxCocoa
import RxSwift
import SnapKit
import Then

class CategoryDetailViewController: BaseViewController<CategoryDetailReactor> {
    // MARK: UI Components

    private let textField = AppTextField().then {
        $0.placeholder = "카테고리 이름을 입력해주세요"
    }

    private let bottomButton = GlowButton(title: "")

    // MARK: CollectionView

    // 0~11 고정 팔레트
    private let palette: [UIColor] = [
        .category0, .category1, .category2, .category3,
        .category4, .category5, .category6, .category7,
        .category8, .category9, .category10, .category11,
    ]

    lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: makeLayout()
    ).then {
        $0.backgroundColor = .clear
        $0.alwaysBounceVertical = false
    }

    lazy var dataSource = makeDataSource(collectionView)

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textField.becomeFirstResponder()
    }

    override func setupUI() {
        view.backgroundColor = .appBackground

        view.addSubview(textField)
        view.addSubview(collectionView)
        view.addSubview(bottomButton)

        textField.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.trailing.leading.equalToSuperview().inset(20)
            $0.height.equalTo(42)
        }

        collectionView.snp.makeConstraints {
            $0.top.equalTo(textField.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(bottomButton.snp.top)
        }

        bottomButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            $0.height.equalTo(54)
        }
    }

    override func bind(reactor: CategoryDetailReactor) {
        // 상단 타이틀 & 하단 버튼
        title = reactor.currentState.navTitle
        bottomButton.setTitle(reactor.currentState.buttonTitle, for: .normal)

        // 초기값 세팅
        configureInitialState(reactor: reactor)

        bottomButton.rx.tap
            .bind { [weak self] _ in
                guard let self, let reactor = self.reactor else { return }
                let title = self.textField.text ?? ""
                let colorId = self.collectionView.indexPathsForSelectedItems?.first?.item ?? 0
                reactor.action.onNext(.tapBottomButton(title, colorId))
            }
            .disposed(by: disposeBag)

        reactor.pulse(\.$alertMessage)
            .withUnretained(self)
            .flatMap { `self`, message in
                UIAlertController.rx.alert(on: self, message: message, actions: [
                    .action("확인", payload: ()),
                ])
            }
            .bind {}
            .disposed(by: disposeBag)
    }
}

extension CategoryDetailViewController {
    // MARK: 초기값 바인딩

    private func configureInitialState(reactor: CategoryDetailReactor) {
        let selectedColorId = reactor.currentState.selectedColorId
        switch reactor.mode {
        case .create:
            applySnapshot(palette, colorId: selectedColorId)
            return
        case let .update(category):
            textField.text = category.name
            applySnapshot(palette, colorId: selectedColorId)
        }
    }

    // MARK: CollectionView 함수들

    private func makeDataSource(_ collectionView: UICollectionView) -> UICollectionViewDiffableDataSource<Int, UIColor> {
        let cellRegistration = UICollectionView.CellRegistration<ColorChipCell, UIColor> { cell, _, color in
            cell.color = color
        }
        return UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
    }

    private func applySnapshot(_ items: [UIColor], colorId: Int) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, UIColor>()
        snapshot.appendSections([0])
        snapshot.appendItems(items, toSection: 0)
        dataSource.apply(snapshot) {
            // 생성시에는 0
            self.collectionView.selectItem(at: IndexPath(item: colorId, section: 0), animated: false, scrollPosition: [])
        }
    }

    private func makeLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { _, enviroment in
            let layoutItem = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .absolute(44),
                    heightDimension: .absolute(44)
                )
            )

            // 좌우인셋 -20, 마지막 아이템 간격 +16
            let width = (enviroment.container.effectiveContentSize.width - 40) + 16
            let itemCount = Int(width / 60)

            let layoutGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(44)
                ),
                repeatingSubitem: layoutItem,
                count: itemCount
            )
            layoutGroup.interItemSpacing = .flexible(16)

            let sectionBackground = NSCollectionLayoutDecorationItem.background(elementKind: ColorChipBacgroundView.identifier)
            return NSCollectionLayoutSection(group: layoutGroup).then {
                $0.interGroupSpacing = 16
                $0.decorationItems = [sectionBackground]
                $0.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20)
            }
        }
        layout.register(ColorChipBacgroundView.self, forDecorationViewOfKind: ColorChipBacgroundView.identifier)
        return layout
    }
}
