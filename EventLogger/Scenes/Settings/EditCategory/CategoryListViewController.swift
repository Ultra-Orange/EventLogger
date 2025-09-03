//
//  CategoryListViewController.swift
//  EventLogger
//
//  Created by Yoon on 8/31/25.
//

import ReactorKit
import RxCocoa
import RxSwift
import SnapKit
import Then
import UIKit

import Dependencies

class CategoryListViewController: BaseViewController<CategoryListReactor> {
    // MARK: UI Component

    let addButton = UIButton(configuration: .bottomButton).then {
        $0.configuration?.title = "추가하기"
    }

    let tmpLabel = UILabel().then {
        $0.text = "여기에 카테고리 편집 추가"
        $0.textColor = .label
    }

    // CollectionView

    let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout.list(using: UICollectionLayoutListConfiguration(appearance: .insetGrouped))
    ).then {
        $0.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 0)
    }

    lazy var dataSource = makeDataSource(collectionView)

    let reorderCategoryRelay = PublishRelay<[CategoryItem]>()
    let deleteCategoryRelay = PublishRelay<CategoryItem>()

    // TODO: 백 스와이프 해제애니메이션이 없이 바로 해제
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let selectedIndexPaths = collectionView.indexPathsForSelectedItems, let transitionCoordinator else {
            return
        }
        transitionCoordinator.animate { [collectionView] _ in
            for indexPath in selectedIndexPaths {
                collectionView.deselectItem(at: indexPath, animated: true)
            }
        } completion: { [collectionView] context in
            if context.isCancelled {
                for indexPath in selectedIndexPaths {
                    collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
                }
            }
        }
    }

    // MARK: SetupUI

    override func setupUI() {
        view.backgroundColor = .systemBackground
        title = "카테고리 목록"
        navigationItem.rightBarButtonItem = editButtonItem

        view.addSubview(collectionView)
        view.addSubview(addButton)

        collectionView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(addButton.snp.top)
        }

        addButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            $0.height.equalTo(54)
        }
    }

    // MARK: Binding

    override func bind(reactor: CategoryListReactor) {
        reactor.state.map { $0.categories }
            .bind { [weak self] items in
                guard let self else { return }
                applySnapshot(items)
            }
            .disposed(by: disposeBag)

        reorderCategoryRelay.map { items in .reorderCategories(items) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        deleteCategoryRelay
            .withUnretained(self)
            .flatMap { `self`, item in
                UIAlertController.rx.alert(on: self, title: "카테고리 삭제", message: "정말로 이 카테고리 삭제하시겠습니까?", actions: [
                    .cancel("취소"),
                    .destructive("삭제", payload: item),
                ])
            }
            .map { item in .deleteCategory(item) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        reactor.pulse(\.$alertMessage)
            .withUnretained(self)
            .flatMap { `self`, message in
                UIAlertController.rx.alert(on: self, title: "삭제 실패", message: message, actions: [
                    .action("확인", payload: ()),
                ])
            }
            .bind {}
            .disposed(by: disposeBag)

        rx.viewWillAppear.map { _ in .reloadCategories }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        addButton.rx.tap
            .map { AppStep.createCategory }
            .bind(to: reactor.steps)
            .disposed(by: disposeBag)

        collectionView.rx.itemSelected
            .withUnretained(self)
            .bind { `self`, indexPath in
                if let item = self.dataSource.itemIdentifier(for: indexPath) {
                    reactor.steps.accept(AppStep.updateCategory(item))
                }
            }
            .disposed(by: disposeBag)
    }
}

extension CategoryListViewController {
    // 편집 모드
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        collectionView.isEditing = editing
    }

    private func makeDataSource(_ collectionView: UICollectionView) -> UICollectionViewDiffableDataSource<Int, CategoryItem> {
        let deleteRelay = deleteCategoryRelay
        let cellRegistration = UICollectionView.CellRegistration<CategoryListCell, CategoryItem> { cell, _, item in
            cell.configureCell(item: item)
            cell.accessories = [
                .disclosureIndicator(displayed: .whenNotEditing, options: UICellAccessory.DisclosureIndicatorOptions(tintColor: .neutral50)),
                .reorder(displayed: .whenEditing, options: UICellAccessory.ReorderOptions(tintColor: .neutral50)),
                .delete(displayed: .whenEditing, options: UICellAccessory.DeleteOptions(tintColor: .neutral50, backgroundColor: .systemRed)) {
                    deleteRelay.accept(item)
                },
            ]
        }

        var reorderingHandlers = UICollectionViewDiffableDataSource<Int, CategoryItem>.ReorderingHandlers()
        reorderingHandlers.canReorderItem = { _ in true }
        reorderingHandlers.didReorder = { [weak self] _ in
            guard let self else { return }
            let updatedItems = self.dataSource.snapshot(for: 0).items
            reorderCategoryRelay.accept(updatedItems)
        }

        let dataSource = UICollectionViewDiffableDataSource<Int, CategoryItem>(collectionView: collectionView) { collectionView, indexPath, text in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: text)
        }
        dataSource.reorderingHandlers = reorderingHandlers

        return dataSource
    }

    func applySnapshot(_ items: [CategoryItem]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, CategoryItem>()
        snapshot.appendSections([0])
        snapshot.appendItems(items, toSection: 0)
        dataSource.apply(snapshot)
    }
}
