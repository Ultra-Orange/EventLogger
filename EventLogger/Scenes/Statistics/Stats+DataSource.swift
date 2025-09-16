//
//  Stats+DataSource.swift
//  EventLogger
//
//  Created by 김우성 on 9/3/25.
//

import UIKit

extension StatsContentViewController {
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
                isMonthEnabled: { month in
                    let months = reactor.currentState.activeMonths
                    return months.contains(month)
                },
                onYearPicked: { [weak reactor] year in reactor?.action.onNext(.pickYear(year)) },
                onMonthPicked: { [weak reactor] month in
                    guard let reactor = reactor else { return }
                    let enabled = reactor.currentState.activeMonths.contains(month)
                    if enabled { reactor.action.onNext(.pickMonth(month)) }
                }
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

        let parentReg = UICollectionView.CellRegistration<StatsRollupParentCell, RollupParent> { [weak self] cell, _, model in
            guard let self = self else { return }
            cell.configure(title: model.title,
                           valueText: model.valueText,
                           leftDotColor: model.leftDotColor)

            // chevron (expanded 여부에 따라 up/down)
            let isExpanded = self.expandedParentIDs.contains(model.id)
            cell.setChevron(expanded: isExpanded, animated: false)

            // 터치 중 하이라이트만 적용되고 선택 잔상은 남지 않도록
            cell.automaticallyUpdatesBackgroundConfiguration = false
            cell.configurationUpdateHandler = { cell, state in
                var bg = UIBackgroundConfiguration.listGroupedCell()
                if state.isHighlighted || state.isSelected {
                    bg.backgroundColor = UIColor.neutral700.withAlphaComponent(0.55)
                } else {
                    bg.backgroundColor = .clear
                }
                (cell as? StatsRollupParentCell)?.backgroundConfiguration = bg
            }
        }

        let childReg = UICollectionView.CellRegistration<StatsRollupChildCell, RollupChild> { cell, _, model in
            cell.configure(title: model.title, valueText: model.valueText, leftDotColor: model.leftDotColor)

            cell.automaticallyUpdatesBackgroundConfiguration = false
            cell.configurationUpdateHandler = { cell, state in
                var bg = UIBackgroundConfiguration.listGroupedCell()
                if state.isHighlighted || state.isSelected {
                    bg.backgroundColor = UIColor.neutral700.withAlphaComponent(0.45)
                } else {
                    bg.backgroundColor = .clear
                }
                (cell as? StatsRollupChildCell)?.backgroundConfiguration = bg
            }
        }

        let titleReg = UICollectionView.CellRegistration<StatsTitleCell, String> { cell, _, title in
            cell.configure(title: title)
        }

        let heatmapHeaderReg = UICollectionView.CellRegistration<HeatmapHeaderCell, String> { cell, _, title in
            cell.configure(title: title)
        }

        let legendReg = UICollectionView.CellRegistration<HeatmapFooterCell, UUID> { cell, _, _ in
            cell.configure()
        }

        dataSource = UICollectionViewDiffableDataSource<StatsSection, StatsItem>(collectionView: collectionView) { collectionView, indexPath, item in
            switch item {
            case let .title(title):
                return collectionView.dequeueConfiguredReusableCell(using: titleReg, for: indexPath, item: title)
            case let .menu(id):
                return collectionView.dequeueConfiguredReusableCell(using: menuReg, for: indexPath, item: id)
            case let .heatmapHeaderTitle(title):
                return collectionView.dequeueConfiguredReusableCell(using: heatmapHeaderReg, for: indexPath, item: title)
            case let .heatmap(model):
                return collectionView.dequeueConfiguredReusableCell(using: heatmapReg, for: indexPath, item: model)
            case let .heatmapLegend(id):
                return collectionView.dequeueConfiguredReusableCell(using: legendReg, for: indexPath, item: id)
            case let .totalCount(model):
                return collectionView.dequeueConfiguredReusableCell(using: totalCountReg, for: indexPath, item: model)
            case let .totalExpense(model):
                return collectionView.dequeueConfiguredReusableCell(using: totalExpenseReg, for: indexPath, item: model)
            case let .rollupParent(model):
                return collectionView.dequeueConfiguredReusableCell(using: parentReg, for: indexPath, item: model)
            case let .rollupChild(model):
                return collectionView.dequeueConfiguredReusableCell(using: childReg, for: indexPath, item: model)
            }
        }

        dataSource.supplementaryViewProvider = nil
    }
}
