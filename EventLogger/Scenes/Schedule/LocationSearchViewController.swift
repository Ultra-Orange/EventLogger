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
    
    // MARK: Rx
    private let disposeBag = DisposeBag()
    private let selectedLocationRelay: PublishRelay<String>
    
    // MARK: MapKit
    private let completer = MKLocalSearchCompleter()
    private let completerResults = BehaviorRelay<[MKLocalSearchCompletion]>(value: [])
    
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
        
        setupUI()
        bind()
    }
    
    private func setupUI() {
        view.addSubview(collectionView)
        view.addSubview(searchBar)
        
        searchBar.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.leading.trailing.equalToSuperview().inset(16)
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
            .skip(1)
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .bind { [weak self] text in
                self?.completer.queryFragment = text
            }
            .disposed(by: disposeBag)
        
        // completerResults → collectionView 반영
        completerResults
            .observe(on: MainScheduler.instance)
            .bind { [weak self] completions in
                guard let self = self else { return }
                var snapshot = NSDiffableDataSourceSnapshot<LocationSection, LocationItem>()
                snapshot.appendSections([.main])
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
    }
    
    
    // MARK: CollectionView DataSource & Layout
    func makeDataSource(_ collectionView: UICollectionView) -> UICollectionViewDiffableDataSource<LocationSection, LocationItem> {
        
        // 셀 정의
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, LocationItem> { cell, _, item in
            var content = UIListContentConfiguration.valueCell()
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
        return dataSource
    }
    
    func makeLayout() -> UICollectionViewLayout {
        let configuration = UICollectionLayoutListConfiguration(appearance: .plain) // 리스트형 레이아웃
        return UICollectionViewCompositionalLayout { _, environment in
            NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: environment)
        }
        
    }
    
}

// MARK: MKLocalSearchCompleterDelegate
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
    case main
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
