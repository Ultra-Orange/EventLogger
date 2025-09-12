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

        // 스냅샷을 다시 그릴 때마다 캐시 초기화
        resetRollupCaches()

        let state = reactor.currentState

        var snapshot = NSDiffableDataSourceSnapshot<StatsSection, StatsItem>()

        // 1) 섹션 구성
        if state.scope == .year || state.scope == .month {
            snapshot.appendSections(
                [
                    .menuBar,
                    .totalCount, .totalExpense,
                    .categoryCountHeader, .categoryCount,
                    .categoryExpenseHeader, .categoryExpense,
                    .artistCountHeader, .artistCount,
                    .artistExpenseHeader, .artistExpense,
                ]
            )
        } else { // .all
            snapshot.appendSections(
                [
                    .heatmapHeader, .heatmap, .heatmapFooter,
                    .totalCount, .totalExpense,
                    .categoryCountHeader, .categoryCount,
                    .categoryExpenseHeader, .categoryExpense,
                    .artistCountHeader, .artistCount,
                    .artistExpenseHeader, .artistExpense,
                ]
            )
        }

        // 2) 메뉴바
        if snapshot.sectionIdentifiers.contains(.menuBar) {
            snapshot.appendItems([.menu(UUID())], toSection: .menuBar)
        }

        // 3) 히트맵
        if snapshot.sectionIdentifiers.contains(.heatmapHeader) {
            snapshot.appendItems([.heatmapHeaderTitle("활동 리포트")], toSection: .heatmapHeader)
        }

        if snapshot.sectionIdentifiers.contains(.heatmap) {
            snapshot.appendItems([.heatmap(reactor.currentState.heatmap)], toSection: .heatmap)
        }

        if snapshot.sectionIdentifiers.contains(.heatmapFooter) {
            snapshot.appendItems([.heatmapLegend(UUID())], toSection: .heatmapFooter)
        }

        // 4) 기간
        let period: StatsPeriod = {
            let currentYear = Calendar.current.component(.year, from: Date())
            let fallbackYear = state.activeYears.first.flatMap(Int.init) ?? currentYear

            switch state.scope {
            case .all:
                return .all
            case .year:
                return .year(state.selectedYear ?? fallbackYear)
            case .month:
                return .yearMonth(
                    year: state.selectedYear ?? fallbackYear,
                    month: state.selectedMonth ?? 1
                )
            }
        }()

        // 5) 총합
        let (cnt, expense) = statisticsService.total(for: period)

//        if cnt == 0 {
//            collectionView.backgroundView?.isHidden = false
//            collectionView.showsVerticalScrollIndicator = false
//
//            // 비어있는 스냅샷 적용 (아이템/섹션 0개여야 backgroundView가 보입니다)
//            let empty = NSDiffableDataSourceSnapshot<StatsSection, StatsItem>()
//            dataSource.apply(empty, animatingDifferences: animated)
//            return
//        } else {
//            collectionView.backgroundView?.isHidden = true
//            collectionView.showsVerticalScrollIndicator = true
//        }

        snapshot.appendItems([.totalCount(.init(totalCount: cnt, totalExpense: expense))], toSection: .totalCount)
        snapshot.appendItems([.totalExpense(.init(totalCount: cnt, totalExpense: expense))], toSection: .totalExpense)

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

    /// '처음에는 숨김' + '펼쳐진 부모만 자식 표시' 지원
    func appendRollup(
        parents: [RollupParent],
        makeChildren: (RollupParent) -> [RollupChild],
        into snapshot: inout NSDiffableDataSourceSnapshot<StatsSection, StatsItem>,
        section: StatsSection
    ) {
        var items: [StatsItem] = []
        for p in parents {
            // 부모는 항상 추가
            items.append(.rollupParent(p))

            // 캐시에 자식 준비 (토글 시 재사용)
            let children = makeChildren(p)
            childrenCache[p.id] = children

            // 이미 펼쳐진 부모라면(예: 스냅샷 재적용 시 유지하고 싶을 때) 자식도 같이 추가
            if expandedParentIDs.contains(p.id) {
                items.append(contentsOf: children.map { .rollupChild($0) })
            }
        }
        snapshot.appendItems(items, toSection: section)
    }
}
