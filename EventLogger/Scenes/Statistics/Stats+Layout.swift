//
//  Stats+Layout.swift
//  EventLogger
//
//  Created by 김우성 on 9/3/25.
//

import UIKit

extension StatsViewController {
    func makeLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout {
            [weak self] sectionIndex,
                env in
            guard let self,
                  let section = self.dataSource?.snapshot().sectionIdentifiers[sectionIndex]
            else { return nil }
            
            switch section {
            case .menuBar: // 완료
                let item = NSCollectionLayoutItem(
                    layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                      heightDimension: .absolute(26))
                )
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                      heightDimension: .absolute(26)),
                    subitems: [item]
                )
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 10, leading: 20, bottom: 0, trailing: 20)
                return section
                
            case .heatmap:
                let item = NSCollectionLayoutItem(
                    layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                      heightDimension: .estimated(40))
                )
                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                      heightDimension: .estimated(40)),
                    subitems: [item]
                )
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 10, leading: 20, bottom: 10, trailing: 20)
                
                // 헤더
                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                      heightDimension: .estimated(22)),
                    elementKind: HeatmapHeaderView.elementKind,
                    alignment: .top
                )
                
                // 푸터
                let footer = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                      heightDimension: .estimated(13)),
                    elementKind: HeatmapFooterView.elementKind,
                    alignment: .bottom
                )
                
                section.boundarySupplementaryItems = [header, footer]
                return section
                
            case .total: // 완료
                let item = NSCollectionLayoutItem(
                    layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                      heightDimension: .estimated(120))
                )
                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                      heightDimension: .estimated(120)),
                    subitems: [item]
                )
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 30, leading: 20, bottom: 20, trailing: 20)
                
                return section
                
            case .categoryCount, .categoryExpense, .artistCount, .artistExpense:
                var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
                config.backgroundColor = .clear
                config.showsSeparators = true
                config.headerMode = .supplementary
                
                let section = NSCollectionLayoutSection.list(using: config, layoutEnvironment: env)
                section.contentInsets = .init(top: 8, leading: 20, bottom: 30, trailing: 20)
                
                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                      heightDimension: .estimated(13)),
                    elementKind: ListHeaderView.elementKind,
                    alignment: .top
                )
                section.boundarySupplementaryItems = [header]
                
                return section
            }
        }
        return layout
    }
}
