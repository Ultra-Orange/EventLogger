//
//  Stats+Layout.swift
//  EventLogger
//
//  Created by 김우성 on 9/3/25.
//

import UIKit

extension StatsViewController {

    /// 컴포지셔널 레이아웃:
    /// - 섹션마다 "레이아웃 규칙"을 다르게 적용할 수 있어요.
    /// - 초보자 Tip: item → group → section 순으로 쌓는 구조입니다.
    func makeLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, env in
            guard let self,
                  let section = self.dataSource?.snapshot().sectionIdentifiers[sectionIndex]
            else { return nil }

            switch section {
            case .menuBar:
                // 얇은 한 줄
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                                                    heightDimension: .estimated(44)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                                                                 heightDimension: .estimated(44)),
                                                               subitems: [item])
                let sec = NSCollectionLayoutSection(group: group)
                sec.contentInsets = .init(top: 0, leading: 20, bottom: 4, trailing: 20)
                return sec

            case .heatmap:
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                                                    heightDimension: .estimated(180)))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                                                               heightDimension: .estimated(220)),
                                                             subitems: [item])
                let sec = NSCollectionLayoutSection(group: group)
                sec.contentInsets = .init(top: 0, leading: 20, bottom: 8, trailing: 20)
                // 헤더 추가
                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                      heightDimension: .estimated(32)),
                    elementKind: StatsHeaderView.elementKind,
                    alignment: .top)
                sec.boundarySupplementaryItems = [header]
                return sec

            case .total:
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                                                    heightDimension: .estimated(120)))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                                                               heightDimension: .estimated(140)),
                                                             subitems: [item])
                let sec = NSCollectionLayoutSection(group: group)
                sec.contentInsets = .init(top: 8, leading: 20, bottom: 8, trailing: 20)
                return sec

            case .categoryCount, .categoryExpense, .artistCount, .artistExpense:
                // 리스트 섹션: 시스템 기본 스타일을 활용하면 separator, inset 등을 쉽게 구성 가능
                var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
                config.backgroundColor = .clear
                config.showsSeparators = true
                config.headerMode = .supplementary
                return NSCollectionLayoutSection.list(using: config, layoutEnvironment: env)
            }
        }
        return layout
    }
}
