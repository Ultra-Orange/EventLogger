//
//  Stats+Snapshot.swift
//  EventLogger
//
//  Created by 김우성 on 9/3/25.
//

import UIKit

extension StatsViewController {
    func applySnapshot(animated: Bool) {
        var snapshot = NSDiffableDataSourceSnapshot<StatsSection, StatsItem>()
        
        if currentScope == .year || currentScope == .month {
            snapshot.appendSections([.menuBar, .total, .categoryCount, .categoryExpense, .artistCount, .artistExpense])
        } else { // .all
            snapshot.appendSections([.heatmap, .total, .categoryCount, .categoryExpense, .artistCount, .artistExpense])
        }
        
        if snapshot.sectionIdentifiers.contains(.menuBar) {
            snapshot.appendItems([.menu(UUID())], toSection: .menuBar)
        }
        
        if snapshot.sectionIdentifiers.contains(.heatmap) {
            snapshot.appendItems([.heatmap(buildHeatmap())], toSection: .heatmap)
        }
        
        // 선택된 기간
        let period: StatsPeriod = {
            switch currentScope {
            case .all: return .all
            case .year: return .year(selectedYear ?? Calendar.current.component(.year, from: Date()))
            case .month: return .yearMonth(year: selectedYear ?? Calendar.current.component(.year, from: Date()),
                                           month: selectedMonth ?? 1)
            }
        }()
        
        // 1) 총합
        let (cnt, expense) = statisticsService.total(for: period)
        snapshot.appendItems([.total(.init(totalCount: cnt, totalExpense: expense))], toSection: .total)
        
        // 2) 상위: 카테고리 Count/Expense
        let categoryStats = statisticsService.categoryStats(for: period) // count desc 정렬
        // Count parents
        let ccParents: [RollupParent] = categoryStats.map { cs in
            RollupParent(
                id: UUID(),
                title: cs.category.name,
                leftDotColor: cs.category.color,
                valueText: "\(cs.count)회",
                type: .categoryCount
            )
        }
        appendRollup(parents: ccParents, makeChildren: { parent in
            // 카테고리 id 매핑
            guard let cid = swiftDataManager.fetchAllCategories().first(where: { $0.name == parent.title })?.id else { return [] }
            let byArtist = statisticsService.artistCountInCategory(for: period, categoryId: cid)
            return byArtist.sorted(by: { $0.value > $1.value }).map {
                RollupChild(id: UUID(), parentId: parent.id, leftDotColor: nil, title: $0.key, valueText: "\($0.value)회")
            }
        }, into: &snapshot, section: .categoryCount)
        
        // Expense parents
        let ceParents: [RollupParent] = categoryStats
            .sorted(by: { $0.totalExpense > $1.totalExpense })
            .map { cs in
                RollupParent(
                    id: UUID(),
                    title: cs.category.name,
                    leftDotColor: cs.category.color,
                    valueText: KRWFormatter.shared.string(cs.totalExpense),
                    type: .categoryExpense
                )
            }
        appendRollup(parents: ceParents, makeChildren: { parent in
            guard let cid = swiftDataManager.fetchAllCategories().first(where: { $0.name == parent.title })?.id else { return [] }
            let byArtist = statisticsService.artistExpenseInCategory(for: period, categoryId: cid)
            return byArtist.sorted(by: { $0.value > $1.value }).map {
                RollupChild(id: UUID(), parentId: parent.id, leftDotColor: nil, title: $0.key, valueText: KRWFormatter.shared.string($0.value))
            }
        }, into: &snapshot, section: .categoryExpense)
        
        // 3) 상위: 아티스트 Count/Expense
        let artistStats = statisticsService.artistStats(for: period) // count desc
        let acParents = artistStats.map { asv in
            RollupParent(id: UUID(), title: asv.name, leftDotColor: nil, valueText: "\(asv.count)회", type: .artistCount)
        }
        appendRollup(parents: acParents, makeChildren: { parent in
            let byCategory = statisticsService.categoryCountForArtist(for: period, artistName: parent.title)
            return byCategory
                .sorted(by: { $0.value > $1.value })
                .map { (cid, v) in
                    let cat = swiftDataManager.fetchOneCategory(id: cid)
                    return RollupChild(id: UUID(), parentId: parent.id, leftDotColor: cat?.color ?? .systemGray,
                                       title: cat?.name ?? "Unknown", valueText: "\(v)회")
                }
        }, into: &snapshot, section: .artistCount)
        
        let aeParents = artistStats
            .sorted(by: { $0.totalExpense > $1.totalExpense })
            .map { asv in
                RollupParent(id: UUID(), title: asv.name, leftDotColor: nil,
                             valueText: KRWFormatter.shared.string(asv.totalExpense), type: .artistExpense)
            }
        appendRollup(parents: aeParents, makeChildren: { parent in
            let byCategory = statisticsService.categoryExpenseForArtist(for: period, artistName: parent.title)
            return byCategory
                .sorted(by: { $0.value > $1.value })
                .map { (cid, v) in
                    let cat = swiftDataManager.fetchOneCategory(id: cid)
                    return RollupChild(id: UUID(), parentId: parent.id, leftDotColor: cat?.color ?? .systemGray,
                                       title: cat?.name ?? "Unknown", valueText: KRWFormatter.shared.string(v))
                }
        }, into: &snapshot, section: .artistExpense)
        
        dataSource.apply(snapshot, animatingDifferences: animated)
    }
    
    func appendRollup(
        parents: [RollupParent],
        makeChildren: (RollupParent) -> [RollupChild],
        into snapshot: inout NSDiffableDataSourceSnapshot<StatsSection, StatsItem>,
        section: StatsSection
    ) {
        var items: [StatsItem] = []
        for p in parents {
            items.append(.rollupParent(p))
            if expandedParents.contains(p.id) {
                let children = makeChildren(p).map { StatsItem.rollupChild($0) }
                items.append(contentsOf: children)
            }
        }
        snapshot.appendItems(items, toSection: section)
    }
}
