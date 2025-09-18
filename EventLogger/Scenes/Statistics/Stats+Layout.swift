//
//  Stats+Layout.swift
//  EventLogger
//
//  Created by 김우성 on 9/3/25.
//

import UIKit

extension StatsContentViewController {
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
            case .menuBar:
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
                section.contentInsets = .init(top: 10, leading: 0, bottom: 0, trailing: 0)
                return section

            case .heatmapHeader:
                let item = NSCollectionLayoutItem(
                    layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                      heightDimension: .estimated(17))
                )
                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                      heightDimension: .estimated(17)),
                    subitems: [item]
                )
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 24, leading: 0, bottom: 0, trailing: 0)
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
                section.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
                section.decorationItems = [decorationItem]
                return section

            case .heatmapFooter:
                let item = NSCollectionLayoutItem(
                    layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                      heightDimension: .estimated(13))
                )
                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                      heightDimension: .estimated(13)),
                    subitems: [item]
                )
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: -10, leading: 0, bottom: 10, trailing: 0)
                return section

            case .totalCount:
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

            case .totalExpense:
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
                section.contentInsets = .init(top: 10, leading: 0, bottom: -10, trailing: 0)
                return section

            case .categoryCount, .categoryExpense, .artistCount, .artistExpense:
                var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
                config.showsSeparators = true

                let section = NSCollectionLayoutSection.list(using: config, layoutEnvironment: env)
                section.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
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
            $0.startPoint = CGPoint(x: 0.25, y: 0.5)
            $0.endPoint = CGPoint(x: 0.75, y: 0.5)
        }

        override init(frame: CGRect) {
            super.init(frame: frame)
            layer.cornerRadius = 10
            layer.masksToBounds = true
            layer.addSublayer(gradientLayer)
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func layoutSubviews() {
            super.layoutSubviews()

            gradientLayer.frame = bounds
        }
    }
}
