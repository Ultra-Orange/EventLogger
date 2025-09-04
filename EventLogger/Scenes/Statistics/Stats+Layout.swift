//
//  Stats+Layout.swift
//  EventLogger
//
//  Created by 김우성 on 9/3/25.
//

import UIKit

extension StatsViewController {
    
    
    func makeLayout() -> UICollectionViewLayout {
        let configuration = UICollectionViewCompositionalLayoutConfiguration().then {
            $0.contentInsetsReference = .layoutMargins
            $0.interSectionSpacing = 20
        }
       
        let sectionProvider: UICollectionViewCompositionalLayoutSectionProvider = {
            [weak self] sectionIndex,
                env in
            guard let self,
                  let section = self.dataSource?.snapshot().sectionIdentifiers[sectionIndex]
            else { return nil }
            
            let decorationItem = NSCollectionLayoutDecorationItem.background(elementKind: "decoration")
            
            switch section {
            case .categoryCountHeader, .categoryExpenseHeader, .artistCountHeader, .artistExpenseHeader:
                let item = NSCollectionLayoutItem(
                    layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                      heightDimension: .estimated(18))
                )
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                      heightDimension: .estimated(18)),
                    subitems: [item]
                )
                let section = NSCollectionLayoutSection(group: group)
                // section.contentInsets = .init(top: 10, leading: 20, bottom: 0, trailing: 20)
                return section

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
                section.contentInsets = .init(top: 10, leading: 0, bottom: 10, trailing: 0)
                section.decorationItems = [decorationItem]
                
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
                
            case .totalCount: // 완료
                let item = NSCollectionLayoutItem(
                    layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                      heightDimension: .estimated(50))
                )
                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                      heightDimension: .estimated(50)),
                    subitems: [item]
                )
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
                section.decorationItems = [decorationItem]
                
                return section
                
            case .totalExpense: // 완료
                let item = NSCollectionLayoutItem(
                    layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                      heightDimension: .estimated(50))
                )
                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                      heightDimension: .estimated(50)),
                    subitems: [item]
                )
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
                section.decorationItems = [decorationItem]
                
                return section
                
                
            case .categoryCount, .categoryExpense, .artistCount, .artistExpense:
                var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
                config.showsSeparators = true

                let section = NSCollectionLayoutSection.list(using: config, layoutEnvironment: env)
                section.contentInsets = .init(top: 8, leading: 0, bottom: 10, trailing: 0)
                section.decorationItems = [decorationItem]
                section.contentInsetsReference = .layoutMargins
                return section
            }
        }
        let layout = UICollectionViewCompositionalLayout(sectionProvider: sectionProvider, configuration: configuration)
        layout.register(DecorationView.self, forDecorationViewOfKind: "decoration")
        return layout
    }
    
    private final class DecorationView: UICollectionReusableView {
        let gradientLayer = CAGradientLayer().then {
            $0.colors = [UIColor.neutral700.withAlphaComponent(0.5).cgColor, UIColor.neutral800.withAlphaComponent(0.8).cgColor]
            $0.startPoint = CGPoint(x: 0.0, y: 0.0)
            $0.endPoint = CGPoint(x: 0.0, y: 1.0)
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            layer.cornerRadius = 10
            layer.masksToBounds = true
            layer.addSublayer(gradientLayer)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            gradientLayer.frame = bounds
        }
    }

}
