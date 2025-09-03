//
//  Stats+DataSource.swift
//  EventLogger
//
//  Created by 김우성 on 9/3/25.
//

import UIKit

extension StatsViewController {
    func configureDataSource() {
        // Cell registrations
        let menuReg = UICollectionView.CellRegistration<StatsMenuBarCell, UUID> { [weak self] cell, _, _ in
            guard let self, let reactor = self.reactor else { return }
            let state = reactor.currentState

            cell.configure(
                scope: state.scope,
                yearProvider: { reactor.currentState.activeYears },
                selectedYear: state.selectedYear,
                selectedMonth: state.selectedMonth,
                onYearPicked: { [weak reactor] y in
                    reactor?.action.onNext(.pickYear(y))
                },
                onMonthPicked: { [weak reactor] m in
                    reactor?.action.onNext(.pickMonth(m))
                }
            )
        }

        let heatmapReg = UICollectionView.CellRegistration<HeatmapCell, HeatmapModel> { cell, _, model in
            cell.configure(model: model)
        }

        let totalReg = UICollectionView.CellRegistration<StatsTotalCell, TotalModel> { cell, _, model in
            cell.configure(totalCount: model.totalCount, totalExpense: model.totalExpense)
        }

        let parentReg = UICollectionView.CellRegistration<StatsRollupParentCell, RollupParent> { [weak self] cell, _, model in
            guard let self, let reactor = self.reactor else { return }
            let expanded = reactor.currentState.expandedParents.contains(model.id)
            cell.configure(title: model.title,
                           valueText: model.valueText,
                           leftDotColor: model.leftDotColor,
                           expanded: expanded)
            cell.onTap = { [weak reactor] in
                reactor?.action.onNext(.toggleParent(model.id))
            }
        }

        let childReg = UICollectionView.CellRegistration<StatsRollupChildCell, RollupChild> { cell, _, model in
            cell.configure(title: model.title, valueText: model.valueText, leftDotColor: model.leftDotColor)
        }

        // Diffable DataSource: 섹션/아이템 → 셀 매핑 규칙
        dataSource = UICollectionViewDiffableDataSource<StatsSection, StatsItem>(collectionView: collectionView) { collectionView, indexPath, item in
            switch item {
            case .menu(let id):
                return collectionView.dequeueConfiguredReusableCell(using: menuReg, for: indexPath, item: id)
            case .heatmap(let model):
                return collectionView.dequeueConfiguredReusableCell(using: heatmapReg, for: indexPath, item: model)
            case .total(let model):
                return collectionView.dequeueConfiguredReusableCell(using: totalReg, for: indexPath, item: model)
            case .rollupParent(let model):
                return collectionView.dequeueConfiguredReusableCell(using: parentReg, for: indexPath, item: model)
            case .rollupChild(let model):
                return collectionView.dequeueConfiguredReusableCell(using: childReg, for: indexPath, item: model)
            }
        }

        // 1) Supplementary Registration (섹션 헤더)
        let headerReg = UICollectionView.SupplementaryRegistration<StatsHeaderView>(
            elementKind: StatsHeaderView.elementKind
        ) { [weak self] header, _, indexPath in
            guard let self,
                  let section = self.dataSource?.snapshot().sectionIdentifiers[indexPath.section]
            else { return }
            let title = self.headerTitle(for: section) ?? ""
            header.configure(title: title, showLegend: section == .heatmap)
        }

        // 2) Provider (헤더 공급자)
        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard kind == StatsHeaderView.elementKind else { return nil }
            return collectionView.dequeueConfiguredReusableSupplementary(using: headerReg, for: indexPath)
        }
    }
}
