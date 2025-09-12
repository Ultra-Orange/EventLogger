//
//  StatsReactor.swift
//  EventLogger
//
//  Created by 김우성 on 9/2/25.
//

import Dependencies
import Foundation
import RxSwift

/// Stats 화면의 단일 진실 소스(Source of Truth)
/// - UI 구성은 VC에서, 상태/도메인 변화는 Reactor에서 담당
final class StatsReactor: BaseReactor {
    @Dependency(\.swiftDataManager) private var swiftDataManager
    private lazy var statisticsService = StatisticsService(manager: swiftDataManager)

    // MARK: - Action (사용자 입력)

    enum Action {
        case viewDidLoad
        case setScope(Scope) // 세그먼트 변경
        case pickYear(Int) // 연도 선택
        case pickMonth(Int) // 월 선택
        case refresh // 데이터 갱신 (외부에서 요청 가능)
    }

    // MARK: - Mutation (상태 변화)

    enum Mutation {
        case setActiveYears([String])
        case setScope(Scope)
        case setSelectedYear(Int?)
        case setSelectedMonth(Int?)
        case setHeatmap(HeatmapModel)
    }

    // MARK: - State (View가 구독)

    struct State {
        var scope: Scope = .year
        var selectedYear: Int?
        var selectedMonth: Int?
        var activeYears: [String] = [] // 메뉴에 그릴 연도 목록
        var heatmap: HeatmapModel = .init(rows: [])
    }

    let initialState: State = .init()

    // MARK: - Dependencies (UI 무관)

    init() {}

    // MARK: - Private helper

    /// 현재 상태에서의 기간 계산 (UI 없이 순수 로직)
    private func currentPeriod(scope: Scope, year: Int?, month: Int?) -> StatsPeriod {
        switch scope {
        case .all: return .all
        case .year: return .year(year ?? Calendar.current.component(.year, from: Date()))
        case .month: return .yearMonth(year: year ?? Calendar.current.component(.year, from: Date()),
                                       month: month ?? 1)
        }
    }

    // MARK: - mutate

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad, .refresh:
            // 진입/새로고침 시 연도 목록과 히트맵 초기화
            let years = statisticsService.activeYears()
            // 기본 연도/월 결정: .year, .month 스코프에서는 반드시 연/월을 세팅
            let currentYear = Calendar.current.component(.year, from: Date())
            let firstActiveYear = years.first.flatMap(Int.init)
            let defaultYear: Int? = {
                // 초기 scope는 .year 이므로 nil 이면 안 됨
                switch currentState.scope {
                case .all: return nil
                case .year, .month:
                    return firstActiveYear ?? currentYear
                }
            }()

            let defaultMonth: Int? = (currentState.scope == .month) ? 1 : nil

            let heatmap = statisticsService.buildHeatmapAll()

            return .concat([
                .just(.setActiveYears(years)),
                .just(.setSelectedYear(defaultYear)),
                .just(.setSelectedMonth(defaultMonth)),
                .just(.setHeatmap(heatmap))
            ])

        case .setScope(let newScope):
            // 스코프 전환 시 기본 선택값 보정
            var selectedYear: Int?
            var selectedMonth: Int? = nil
            if newScope == .year || newScope == .month {
                if let firstYear = statisticsService.activeYears().first, let year = Int(firstYear) {
                    selectedYear = year
                } else {
                    selectedYear = Calendar.current.component(.year, from: Date())
                }
                if newScope == .month { selectedMonth = 1 }
            }
            let years = statisticsService.activeYears()
            return .concat([
                .just(.setScope(newScope)),
                .just(.setSelectedYear(selectedYear)),
                .just(.setSelectedMonth(selectedMonth)),
                .just(.setActiveYears(years))
            ])

        case .pickYear(let year):
            return .just(.setSelectedYear(year))

        case .pickMonth(let month):
            return .just(.setSelectedMonth(month))
        }
    }

    // MARK: - reduce

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setActiveYears(let years):
            newState.activeYears = years

        case .setScope(let scope):
            newState.scope = scope

        case .setSelectedYear(let year):
            newState.selectedYear = year

        case .setSelectedMonth(let month):
            newState.selectedMonth = month

        case .setHeatmap(let model):
            newState.heatmap = model
        }
        return newState
    }
}
