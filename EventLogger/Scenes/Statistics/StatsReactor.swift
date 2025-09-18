//
//  StatsReactor.swift
//  EventLogger
//
//  Created by 김우성 on 9/2/25.
//

import Dependencies
import Foundation
import RxSwift

final class StatsReactor: BaseReactor {
    @Dependency(\.swiftDataManager) private var swiftDataManager
    private lazy var statisticsService = StatisticsService(manager: swiftDataManager)

    enum Action {
        case viewDidLoad
        case setScope(Scope)
        case pickYear(Int)
        case pickMonth(Int)
        case refresh
    }

    enum Mutation {
        case setActiveYears([String])
        case setActiveMonths([Int])
        case setScope(Scope)
        case setSelectedYear(Int?)
        case setSelectedMonth(Int?)
        case setHeatmap(HeatmapModel)
    }

    struct State {
        var scope: Scope = .year
        var selectedYear: Int?
        var selectedMonth: Int?
        var activeYears: [String] = [] // 메뉴에 그릴 연도 목록
        var activeMonths: [Int] = []   // 선택된 연도의 활성화될 월
        var heatmap: HeatmapModel = .init(rows: [])
    }

    let initialState: State

    init(fixedScope: Scope) {
        self.initialState = .init(scope: fixedScope,
                                  selectedYear: nil,
                                  selectedMonth: fixedScope == .month ? 1 : nil,
                                  activeYears: [],
                                  heatmap: .init(rows: []))
    }

    convenience init() {
        self.init(fixedScope: .year)
    }

    private func currentPeriod(scope: Scope, year: Int?, month: Int?) -> StatsPeriod {
        switch scope {
        case .all: return .all
        case .year: return .year(year ?? Calendar.current.component(.year, from: Date()))
        case .month: return .yearMonth(year: year ?? Calendar.current.component(.year, from: Date()),
                                       month: month ?? 1)
        }
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad, .refresh:
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

            let months = (defaultYear != nil) ? statisticsService.activeMonths(in: defaultYear!) : []

            let defaultMonth: Int? = {
                guard currentState.scope == .month else { return nil }
                return months.first
            }()

            let heatmap = statisticsService.buildHeatmapAll()

            return .concat([
                .just(.setActiveYears(years)),
                .just(.setSelectedYear(defaultYear)),
                .just(.setActiveMonths(months)),
                .just(.setSelectedMonth(defaultMonth)),
                .just(.setHeatmap(heatmap)),
            ])

        case let .setScope(newScope):
            // 스코프 전환 시 연/월 재설정
            var selectedYear: Int?
            if newScope == .year || newScope == .month {
                if let firstYear = statisticsService.activeYears().first, let year = Int(firstYear) {
                    selectedYear = year
                } else {
                    selectedYear = Calendar.current.component(.year, from: Date())
                }
            }

            let years = statisticsService.activeYears()
            // 선택 연도 기준 활성 월 계산
            let months = (selectedYear != nil) ? statisticsService.activeMonths(in: selectedYear!) : []
            // .month면 첫 활성 월, 아니면 nil
            let selectedMonth: Int? = (newScope == .month) ? months.first : nil

            return .concat([
                .just(.setScope(newScope)),
                .just(.setSelectedYear(selectedYear)),
                .just(.setActiveYears(years)),
                .just(.setActiveMonths(months)),
                .just(.setSelectedMonth(selectedMonth)),
            ])

        case let .pickYear(year):
            // 연도 바뀌면 활성 월도 갱신, 선택 월은 유지 가능하면 유지, 아니면 첫 활성 월/ nil
            let months = statisticsService.activeMonths(in: year)
            let currentSelectedMonth = currentState.selectedMonth
            let nextSelectedMonth = months.contains(currentSelectedMonth ?? -1) ? currentSelectedMonth : months.first
            return .concat([
                .just(.setSelectedYear(year)),
                .just(.setActiveMonths(months)),
                .just(.setSelectedMonth(nextSelectedMonth)),
            ])

        case let .pickMonth(month):
            // 비활성 월 선택 방지: 액션 레벨에서도 한 번 더 가드
            if let y = currentState.selectedYear {
                let months = statisticsService.activeMonths(in: y)
                guard months.contains(month) else { return .empty() }
            }
            return .just(.setSelectedMonth(month))
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setActiveYears(years):
            newState.activeYears = years

        case let .setActiveMonths(month):
            newState.activeMonths = month

        case let .setScope(scope):
            newState.scope = scope

        case let .setSelectedYear(year):
            newState.selectedYear = year

        case let .setSelectedMonth(month):
            newState.selectedMonth = month

        case let .setHeatmap(model):
            newState.heatmap = model
        }
        return newState
    }
}
