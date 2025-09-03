//
//  Stats+Layout.swift
//  EventLogger
//
//  Created by 김우성 on 9/3/25.
//

import UIKit

extension StatsViewController {

    func makeLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, env in
            guard let self,
                  let section = self.dataSource?.snapshot().sectionIdentifiers[sectionIndex]
            else { return nil }

            switch section {
            case .menuBar:
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                                                    heightDimension: .estimated(26)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                                                                 heightDimension: .estimated(26)),
                                                               subitems: [item])
                let sec = NSCollectionLayoutSection(group: group)
                sec.contentInsets = .init(top: 10, leading: 20, bottom: 10, trailing: 20)
                return sec

            case .heatmap:
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                                                    heightDimension: .estimated(180)))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                                                               heightDimension: .estimated(220)),
                                                             subitems: [item])
                let sec = NSCollectionLayoutSection(group: group)
                sec.contentInsets = .init(top: 20, leading: 20, bottom: 20, trailing: 20)
                
                // 헤더
                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                      heightDimension: .estimated(32)),
                    elementKind: StatsHeaderView.elementKind,
                    alignment: .top)
                
                // 푸터 (HeatmapLegend)
                let footer = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                      heightDimension: .estimated(13)),
                    elementKind: HeatmapFooterView.elementKind,
                    alignment: .bottom)
                
                sec.boundarySupplementaryItems = [header, footer]
                
                return sec

            case .total:
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                                                    heightDimension: .estimated(120)))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                                                               heightDimension: .estimated(120)),
                                                             subitems: [item])
                let sec = NSCollectionLayoutSection(group: group)
                sec.contentInsets = .init(top: 10, leading: 20, bottom: 10, trailing: 20)
                return sec

            case .categoryCount, .categoryExpense, .artistCount, .artistExpense:
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
