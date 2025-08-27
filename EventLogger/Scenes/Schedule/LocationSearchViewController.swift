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
        searchBar.rx.text.orEmpty
            .skip(1) // 첫 빈 문자열 무시
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .withUnretained(self)
            .flatMap { `self`, query in
                self.searhLocations(query: query)
            }
            .bind { [dataSource] mapItems in
                var snapshot = NSDiffableDataSourceSnapshot<LocationSection, LocationItem>()
                snapshot.appendSections([.main])
                
                let locationItems = mapItems.map { LocationItem(mapItem: $0) }
                
                snapshot.appendItems(locationItems)
                dataSource.apply(snapshot, animatingDifferences: false)
                
            }
            .disposed(by: disposeBag)
        
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
    
    private func searhLocations(query: String) -> Observable<[MKMapItem]> {
        return Observable.create { observer in
            
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = query
            request.region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 37.2636, longitude: 127.0286), // 수원 중심 좌표
                span: MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3)
            )
            
            
            let search = MKLocalSearch(request: request)
            search.start { response, error in
                if let error = error {
                    print("검색 오류:", error.localizedDescription)
                    observer.onError(error)
                    return
                }
                
                guard let items = response?.mapItems else {
                    print("검색 결과 없음")
                    observer.onNext([])
                    observer.onCompleted()
                    return
                }
                observer.onNext(items)
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
        .catchAndReturn([])
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
    let coordinate: CLLocationCoordinate2D?
    
    init(mapItem: MKMapItem) {
        self.title = mapItem.name ?? "이름 없음"
        self.coordinate = mapItem.placemark.coordinate
        self.subtitle = mapItem.placemark.title // 주소 문자열
    }
    
    init(customTitle: String) {
        self.title = customTitle
        self.coordinate = nil
        self.subtitle = nil
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id) // UUID 기반으로 고유성 확보
    }
    
    static func == (lhs: LocationItem, rhs: LocationItem) -> Bool {
        return lhs.id == rhs.id
    }
}
