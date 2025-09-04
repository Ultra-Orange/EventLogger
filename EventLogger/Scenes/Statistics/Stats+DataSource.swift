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
                onYearPicked: { [weak reactor] y in reactor?.action.onNext(.pickYear(y)) },
                onMonthPicked: { [weak reactor] m in reactor?.action.onNext(.pickMonth(m)) }
            )
        }

        let heatmapReg = UICollectionView.CellRegistration<StatsHeatmapCell, HeatmapModel> { cell, _, model in
            cell.configure(model: model)
        }

        let totalCountReg = UICollectionView.CellRegistration<StatsTotalCountCell, TotalModel> { cell, _, model in
            cell.configure(totalCount: model.totalCount)
        }
        
        let totalExpenseReg = UICollectionView.CellRegistration<StatsTotalExpenseCell, TotalModel> { cell, _, model in
            cell.configure(totalExpense: model.totalExpense)
        }

        let parentReg = UICollectionView.CellRegistration<StatsRollupParentCell, RollupParent> { cell, _, model in
            cell.configure(title: model.title,
                           valueText: model.valueText,
                           leftDotColor: model.leftDotColor)
        }

        let childReg = UICollectionView.CellRegistration<StatsRollupChildCell, RollupChild> { cell, _, model in
            cell.configure(title: model.title, valueText: model.valueText, leftDotColor: model.leftDotColor)
        }

        let titleReg = UICollectionView.CellRegistration<StatsTitleCell, String> { cell, _, title in
            cell.configure(title: title)
        }
        dataSource = UICollectionViewDiffableDataSource<StatsSection, StatsItem>(collectionView: collectionView) { collectionView, indexPath, item in
            switch item {
            case .title(let title):
                return collectionView.dequeueConfiguredReusableCell(using: titleReg, for: indexPath, item: title)
            case .menu(let id):
                return collectionView.dequeueConfiguredReusableCell(using: menuReg, for: indexPath, item: id)
            case .heatmap(let model):
                return collectionView.dequeueConfiguredReusableCell(using: heatmapReg, for: indexPath, item: model)
            case .totalCount(let model):
                return collectionView.dequeueConfiguredReusableCell(using: totalCountReg, for: indexPath, item: model)
            case .totalExpense(let model):
                return collectionView.dequeueConfiguredReusableCell(using: totalExpenseReg, for: indexPath, item: model)
            case .rollupParent(let model):
                return collectionView.dequeueConfiguredReusableCell(using: parentReg, for: indexPath, item: model)
            case .rollupChild(let model):
                return collectionView.dequeueConfiguredReusableCell(using: childReg, for: indexPath, item: model)
            }
        }

        // 1) Header Registration
        let heatmapHeaderReg = UICollectionView.SupplementaryRegistration<HeatmapHeaderView>(
            elementKind: HeatmapHeaderView.elementKind
        ) { [weak self] header, _, indexPath in
            guard let self,
                  let section = self.dataSource?.snapshot().sectionIdentifiers[indexPath.section],
                  section == .heatmap
            else { return }
            let title = self.headerTitle(for: section) ?? ""
            header.configure(title: title, showLegend: true)
        }

        // 2) Footer Registration (HeatmapLegend)
        let footerReg = UICollectionView.SupplementaryRegistration<HeatmapFooterView>(
            elementKind: HeatmapFooterView.elementKind
        ) { footer, _, _ in
            footer.configure(title: "", showLegend: true)
        }

        // 3) Provider
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            if kind == HeatmapHeaderView.elementKind {
                return collectionView.dequeueConfiguredReusableSupplementary(using: heatmapHeaderReg, for: indexPath)
            } else if kind == HeatmapFooterView.elementKind {
                return collectionView.dequeueConfiguredReusableSupplementary(using: footerReg, for: indexPath)
            }
            return nil
        }
    }
}
