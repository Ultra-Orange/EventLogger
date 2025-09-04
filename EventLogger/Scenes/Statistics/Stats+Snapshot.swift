//
//  Stats+Snapshot.swift
//  EventLogger
//
//  Created by 김우성 on 9/3/25.
//

import UIKit

extension StatsViewController {

    func applySnapshot(animated: Bool) {
        guard let reactor = reactor, let dataSource = dataSource else { return }
        let state = reactor.currentState

        var snapshot = NSDiffableDataSourceSnapshot<StatsSection, StatsItem>()

        // 1) 섹션 구성
        if state.scope == .year || state.scope == .month {
            snapshot.appendSections([.menuBar, .total, .categoryCountHeader, .categoryCount, .categoryExpenseHeader, .categoryExpense, .artistCountHeader, .artistCount, .artistExpenseHeader, .artistExpense])
        } else { // .all
            snapshot.appendSections([.heatmap, .total, .categoryCountHeader, .categoryCount, .categoryExpenseHeader, .categoryExpense, .artistCountHeader, .artistCount, .artistExpenseHeader, .artistExpense])
        }

        // 2) 메뉴바
        if snapshot.sectionIdentifiers.contains(.menuBar) {
            snapshot.appendItems([.menu(UUID())], toSection: .menuBar)
        }

        // 3) 히트맵
        if snapshot.sectionIdentifiers.contains(.heatmap) {
            snapshot.appendItems([.heatmap(reactor.currentState.heatmap)], toSection: .heatmap)
        }

        // 4) 기간
        let period: StatsPeriod = {
            switch state.scope {
            case .all: return .all
            case .year: return .year(state.selectedYear ?? Calendar.current.component(.year, from: Date()))
            case .month: return .yearMonth(year: state.selectedYear ?? Calendar.current.component(.year, from: Date()),
                                           month: state.selectedMonth ?? 1)
            }
        }()

        // 5) 총합
        let (cnt, expense) = statisticsService.total(for: period)
        snapshot.appendItems([.total(.init(totalCount: cnt, totalExpense: expense))], toSection: .total)

        // 6) 카테고리 Count/Expense (하위 포함)
        let categoryStats = statisticsService.categoryStats(for: period) // count desc

        snapshot.appendItems([.title("카테고리별 참여 횟수")], toSection: .categoryCountHeader)

        let ccParents: [RollupParent] = categoryStats.map { cs in
            RollupParent(
                id: UUID(),
                title: cs.category.name,
                leftDotColor: cs.category.color,
                valueText: "\(cs.count)회",
                type: .categoryCount
            )
        }

        appendRollup(
            parents: ccParents,
            makeChildren: { parent in
                // parent.title == category name
                guard let cs = categoryStats.first(where: { $0.category.name == parent.title }) else { return [] }
                return cs.topArtistsByCount.map {
                    RollupChild(
                        id: UUID(),
                        parentId: parent.id,
                        leftDotColor: nil,
                        title: $0.name,
                        valueText: "\($0.count)회"
                    )
                }
            },
            into: &snapshot,
            section: .categoryCount
        )

        snapshot.appendItems([.title("카테고리별 지출")], toSection: .categoryExpenseHeader)

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

        appendRollup(
            parents: ceParents,
            makeChildren: { parent in
                guard let cs = categoryStats.first(where: { $0.category.name == parent.title }) else { return [] }
                return cs.topArtistsByExpense.map {
                    RollupChild(
                        id: UUID(),
                        parentId: parent.id,
                        leftDotColor: nil,
                        title: $0.name,
                        valueText: KRWFormatter.shared.string($0.expense)
                    )
                }
            },
            into: &snapshot,
            section: .categoryExpense
        )

        // 7) 아티스트 Count/Expense (하위 포함)
        let artistStats = statisticsService.artistStats(for: period) // count desc

        snapshot.appendItems([.title("아티스트별 참여 횟수")], toSection: .artistCountHeader)

        let acParents = artistStats.map { asv in
            RollupParent(
                id: UUID(),
                title: asv.name,
                leftDotColor: nil,
                valueText: "\(asv.count)회",
                type: .artistCount
            )
        }

        appendRollup(
            parents: acParents,
            makeChildren: { parent in
                guard let asv = artistStats.first(where: { $0.name == parent.title }) else { return [] }
                return asv.topCategoriesByCount.map {
                    RollupChild(
                        id: UUID(),
                        parentId: parent.id,
                        leftDotColor: $0.category.color,
                        title: $0.category.name,
                        valueText: "\($0.count)회"
                    )
                }
            },
            into: &snapshot,
            section: .artistCount
        )

        snapshot.appendItems([.title("아티스트별 지출")], toSection: .artistExpenseHeader)

        let aeParents = artistStats
            .sorted(by: { $0.totalExpense > $1.totalExpense })
            .map { asv in
                RollupParent(
                    id: UUID(),
                    title: asv.name,
                    leftDotColor: nil,
                    valueText: KRWFormatter.shared.string(asv.totalExpense),
                    type: .artistExpense
                )
            }

        appendRollup(
            parents: aeParents,
            makeChildren: { parent in
                guard let asv = artistStats.first(where: { $0.name == parent.title }) else { return [] }
                return asv.topCategoriesByExpense.map {
                    RollupChild(
                        id: UUID(),
                        parentId: parent.id,
                        leftDotColor: $0.category.color,
                        title: $0.category.name,
                        valueText: KRWFormatter.shared.string($0.expense)
                    )
                }
            },
            into: &snapshot,
            section: .artistExpense
        )

        dataSource.apply(snapshot, animatingDifferences: animated)
    }

    /// 펼침/접힘 제거: 항상 부모 다음에 자식을 이어 붙입니다.
    func appendRollup(
        parents: [RollupParent],
        makeChildren: (RollupParent) -> [RollupChild],
        into snapshot: inout NSDiffableDataSourceSnapshot<StatsSection, StatsItem>,
        section: StatsSection
    ) {
        var items: [StatsItem] = []
        for p in parents {
            items.append(.rollupParent(p))
            let children = makeChildren(p).map { StatsItem.rollupChild($0) }
            items.append(contentsOf: children)
        }
        snapshot.appendItems(items, toSection: section)
    }
}
