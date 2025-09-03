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
            guard let self else { return }
            cell.configure(
                scope: self.currentScope,
                yearProvider: { [weak self] in self?.statisticsService.activeYears() ?? [] },
                selectedYear: self.selectedYear,
                selectedMonth: self.selectedMonth,
                onYearPicked: { [weak self] y in
                    self?.selectedYear = y
                    self?.applySnapshot(animated: true)
                },
                onMonthPicked: { [weak self] m in
                    self?.selectedMonth = m
                    self?.applySnapshot(animated: true)
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
            guard let self else { return }
            cell.configure(title: model.title,
                           valueText: model.valueText,
                           leftDotColor: model.leftDotColor,
                           expanded: self.expandedParents.contains(model.id))
        }
        
        let childReg = UICollectionView.CellRegistration<StatsRollupChildCell, RollupChild> { cell, _, model in
            cell.configure(title: model.title, valueText: model.valueText, leftDotColor: model.leftDotColor)
        }
        
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
        
        // 1) Supplementary Registration
        let headerReg = UICollectionView.SupplementaryRegistration<StatsHeaderView>(
            elementKind: StatsHeaderView.elementKind
        ) { [weak self] header, _, indexPath in
            guard let self,
                  let section = self.dataSource?.snapshot().sectionIdentifiers[indexPath.section]
            else { return }
            let title = self.headerTitle(for: section) ?? ""
            header.configure(title: title, showLegend: section == .heatmap)
        }

        // 2) Provider
        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard kind == StatsHeaderView.elementKind else { return nil }
            return collectionView.dequeueConfiguredReusableSupplementary(using: headerReg, for: indexPath)
        }
    }
}
