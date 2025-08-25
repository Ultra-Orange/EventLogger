//
//  EventListDataSource.swift
//  EventLogger
//
//  Created by 김우성 on 8/25/25.
//

import UIKit
import SwiftUI

/// Diffable DataSource & 헤더 등록 담당
final class EventListDataSource {
    
    // typealias: 이미 존재하는 타입에 대한 별칭(alias)을 만드는 데 사용하는 키워드
    typealias DS = UICollectionViewDiffableDataSource<EventListSection, EventListDSItem>
    private(set) var dataSource: DS!
    
    private weak var collectionView: UICollectionView?
    private var itemsByID: [UUID: EventItem] = [:]
    
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        configure(collectionView: collectionView)
    }
    
    func updateItemsMap(_ map: [UUID: EventItem]) {
        self.itemsByID = map
    }
    
    func apply(_ snapshot: NSDiffableDataSourceSnapshot<EventListSection, EventListDSItem>, animated: Bool) {
        dataSource.apply(snapshot, animatingDifferences: animated)
    }
    
    private func configure(collectionView: UICollectionView) {
        // Cell: SwiftUI EventCell를 iOS 17의 UIHostingConfiguration으로 올림
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, EventListDSItem> { [weak self] cell, _, item in
            guard let self else { return }
            let event: EventItem? = {
                switch item {
                case .nextUp(let id), .monthEvent(let id): return self.itemsByID[id]
                }
            }()
            guard let event else { return }
            
            cell.contentConfiguration = UIHostingConfiguration {
                EventCell(item: event)
            }.margins(.all, 0)
            cell.backgroundConfiguration = nil
        }
        
        // Header
        let headerRegistration = UICollectionView.SupplementaryRegistration<UICollectionReusableView>(elementKind: UICollectionView.elementKindSectionHeader) { [weak self] header, _, indexPath in
            guard let self else { return }
            let tag = 1001
            let label: UILabel
            if let l = header.viewWithTag(tag) as? UILabel {
                label = l
            } else {
                label = UILabel()
                label.tag = tag
                label.textColor = .white
                label.font = UIFont.preferredFont(forTextStyle: .headline)
                header.addSubview(label)
                label.snp.makeConstraints {
                    $0.top.equalToSuperview().inset(25)
                    $0.bottom.equalToSuperview().inset(20)
                    $0.leading.trailing.equalToSuperview()
                }
            }
            
            let snapshot = self.dataSource.snapshot()
            let section = snapshot.sectionIdentifiers[indexPath.section]
            switch section {
            case .nextUp: label.text = "다음 일정"
            case .month(let yearMonth): label.text = "\(yearMonth.year)년 \(yearMonth.month)월"
            }
        }
        
        // DataSource
        dataSource = DS(collectionView: collectionView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
        }
    }
}
