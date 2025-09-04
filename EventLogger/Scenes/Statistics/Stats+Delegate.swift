//
//  Stats+Delegate.swift
//  EventLogger
//
//  Created by 김우성 on 9/4/25.
//

import UIKit

extension StatsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        guard let dataSource = dataSource,
              let item = dataSource.itemIdentifier(for: indexPath) else { return }

        switch item {
        case .rollupParent(let parent):
            toggle(parent: parent)

        default:
            break
        }
    }

    private func toggle(parent: RollupParent) {
        guard var snapshot = dataSource?.snapshot() else { return }
        let pid = parent.id
        let children = (childrenCache[pid] ?? [])
        let childItems = children.map { StatsItem.rollupChild($0) }
        let parentItem = StatsItem.rollupParent(parent)

        if expandedParentIDs.contains(pid) {
            // 접기: 자식 삭제
            snapshot.deleteItems(childItems)
            expandedParentIDs.remove(pid)
        } else {
            // 펼치기: 부모 바로 뒤에 자식 삽입
            if snapshot.indexOfItem(parentItem) != nil {
                snapshot.insertItems(childItems, afterItem: parentItem)
                expandedParentIDs.insert(pid)
            } else {
                // 혹시 동일성 문제로 못 찾았을 때(매우 드묾): 섹션 끝에라도 추가
                // (실무에서는 assert로 잡아도 됨)
                snapshot.appendItems(childItems, toSection: sectionFor(parent: parent, in: snapshot))
                expandedParentIDs.insert(pid)
            }
        }
        snapshot.reconfigureItems([parentItem]) // chevron 갱신 (cellRegistration의 액세서리 재계산 유도)

        dataSource?.apply(snapshot, animatingDifferences: true)
    }

    /// 부모가 속한 섹션을 찾는 헬퍼 (fallback용)
    private func sectionFor(parent: RollupParent,
                            in snapshot: NSDiffableDataSourceSnapshot<StatsSection, StatsItem>) -> StatsSection {
        // 타입 -> 섹션 매핑
        let section: StatsSection
        switch parent.type {
        case .categoryCount: section = .categoryCount
        case .categoryExpense: section = .categoryExpense
        case .artistCount: section = .artistCount
        case .artistExpense: section = .artistExpense
        }
        // 섹션이 실제 스냅샷에 존재하면 그 섹션 반환, 아니면 첫 섹션
        return snapshot.sectionIdentifiers.contains(section) ? section : (snapshot.sectionIdentifiers.first ?? .categoryCount)
    }
}
