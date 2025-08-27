//
//  LocationSearchViewController.swift
//  EventLogger
//
//  Created by Yoon on 8/26/25.
//

import UIKit
import SnapKit
import Then
import MapKit
import RxSwift
import RxCocoa

class LocationSearchViewController: UIViewController {
    // MARK: UI Components
    lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: makeLayout()
    )
    
    lazy var dataSource = makeDataSource(collectionView)
    
    
    private let searchBar = UISearchBar().then {
        $0.placeholder = "장소를 입력하세요"
    }
    
    private let cancelButton = UIButton(configuration: .navCancel).then {
        $0.configuration?.title = "취소"
    }
    
    // MARK: Rx
    private let disposeBag = DisposeBag()
    private let selectedLocationRelay: PublishRelay<String>
    
    // MARK: MapKit
    private let completer = MKLocalSearchCompleter()
    private let completerResults = BehaviorRelay<[MKLocalSearchCompletion]>(value: [])
    private let currentQuery = BehaviorRelay<String>(value: "")
    
    // MARK: LifeCycle
    init(selectedLocationRelay: PublishRelay<String>) {
        self.selectedLocationRelay = selectedLocationRelay
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        completer.delegate = self
        completer.resultTypes = [.pointOfInterest, .address] // 자동완성 강화
        
        navigationItem.title = "장소 검색"
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: cancelButton)
        
        setupUI()
        bind()
    }
    
    private func setupUI() {
        view.addSubview(collectionView)
        view.addSubview(searchBar)
        
        collectionView.register(LocationSearchSectionHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "HeaderView")
        
        searchBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom).offset(8)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    // Rx 바인딩
    private func bind() {
        // 입력 → completer.queryFragment 업데이트
        searchBar.rx.text.orEmpty
            .skip(1) // 최초 1회 스킵(입력 전)
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .do(onNext: { [weak self] query in
                guard let self else { return }
                self.currentQuery.accept(query)
            })
            .bind { [weak self] text in
                guard let self else { return }
                self.completer.queryFragment = text
            }
            .disposed(by: disposeBag)
        
        // completerResults → collectionView 반영
        completerResults
            .withLatestFrom(currentQuery) { ($0, $1) }
            .observe(on: MainScheduler.instance)
            .bind { [weak self] (completions,query) in
                guard let self = self else { return }
                var snapshot = NSDiffableDataSourceSnapshot<LocationSection, LocationItem>()
                
                // 사용자 입력 섹션
                if !query.trimmingCharacters(in: .whitespaces).isEmpty { // 쿼리가 있다면
                    snapshot.appendSections([.custom])
                    snapshot.appendItems([LocationItem(customTitle: query)], toSection: .custom)
                }
                
                // 검색 결과 섹션
                snapshot.appendSections([.searchResults])
                let items = completions.map { LocationItem(completion: $0) }
                snapshot.appendItems(items)
                self.dataSource.apply(snapshot, animatingDifferences: false)
            }
            .disposed(by: disposeBag)
        
        // 선택 시  Relay 전달
        collectionView.rx.itemSelected
            .withUnretained(self)
            .bind { `self`, indexPath in
                if let item = self.dataSource.itemIdentifier(for: indexPath) {
                    self.selectedLocationRelay.accept(item.title)
                    self.dismiss(animated: true)
                }
            }
            .disposed(by: disposeBag)
        
        cancelButton.rx.tap
            .bind { [weak self] in
                self?.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: CollectionView DataSource & Layout
    func makeDataSource(_ collectionView: UICollectionView) -> UICollectionViewDiffableDataSource<LocationSection, LocationItem> {
        
        // 셀 정의
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, LocationItem> { cell, _, item in
            var content = cell.defaultContentConfiguration()
            content.textProperties.font = .font17Regular
            content.secondaryTextProperties.font = .font12Regular
            content.text = item.title
            content.secondaryText = item.subtitle
            content.secondaryTextProperties.color = .secondaryLabel
            content.secondaryTextProperties.numberOfLines = 1
            cell.contentConfiguration = content
        }
        
        //데이터 소스 정의
        let dataSource = UICollectionViewDiffableDataSource<LocationSection, LocationItem>(
            collectionView: collectionView
        ) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
        
        dataSource.supplementaryViewProvider = { [weak dataSource] collectionView, kind, indexPath in
            guard let section = dataSource?.sectionIdentifier(for: indexPath.section) else { return nil }
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderView", for: indexPath) as! LocationSearchSectionHeaderView
            
            switch section {
            case .custom:
                headerView.titleLabel.text = nil
            case .searchResults:
                headerView.titleLabel.text = "지도 위치"
            }
            return headerView
            
        }
        
        
        return dataSource
    }
    
    func makeLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, environment in
            // config
            var config = UICollectionLayoutListConfiguration(appearance: .plain)
            config.showsSeparators = true
            config.separatorConfiguration.topSeparatorVisibility = .visible
            
            // 섹션
            let section = NSCollectionLayoutSection.list(
                using: config,
                layoutEnvironment: environment
            )
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            
            // 헤더
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(30)),
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            header.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            
            // 조건: .searchResults 섹션에만 헤더 표시
            let currentSection = self.dataSource.snapshot().sectionIdentifiers[sectionIndex]
            if currentSection == .searchResults {
                section.boundarySupplementaryItems = [header]
            }
            return section
        }
        
    }
    
}

// MARK: MKLocalSearchCompleterDelegate
// TODO: DelegateProxy로 변경
extension LocationSearchViewController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        completerResults.accept(completer.results)
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("자동완성 오류: \(error.localizedDescription)")
        completerResults.accept([])
    }
}

// MARK: CollectionView Section & Item
enum LocationSection {
    case custom
    case searchResults
}

// Item 정의 (MKMapItem + 직접 입력 문자열 모두 수용)
struct LocationItem: Hashable {
    
    let id = UUID()
    let title: String
    let subtitle: String?   // 주소 표시용
    
    init(customTitle: String) {
        self.title = customTitle
        self.subtitle = nil
    }
    
    init(completion: MKLocalSearchCompletion) {
        self.title = completion.title
        self.subtitle = completion.subtitle
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id) // UUID 기반으로 고유성 확보
    }
    
    static func == (lhs: LocationItem, rhs: LocationItem) -> Bool {
        return lhs.id == rhs.id
    }
}
