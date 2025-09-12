//
//  DateRangeFieldContainerView.swift
//  EventLogger
//
//  Created by 김우성 on 8/26/25.
//

import RxCocoa
import RxSwift
import SnapKit
import Then
import UIKit

final class DateRangeFieldContainerView: UIView {
    // MARK: API

    /// 외부에서 읽기/설정 가능한 시작/종료 날짜 (설정 시 UI 동기화)
    var startDate: Date { didSet { syncStartUI() } }
    var endDate: Date { didSet { syncEndUI() } }
    
    /// 값 변경을 외부로 내보내기
    let startDateChanged = PublishRelay<Date>()
    let endDateChanged = PublishRelay<Date>()
    
    // MARK: UI

    private let sectionHeader = UILabel().then {
        $0.text = "날짜 및 시간"
        $0.font = .font13Regular
        $0.textColor = .neutral50
    }
    
    private let cardView = UIView().then {
        $0.backgroundColor = .systemGray5 // Neutral/800 으로 수정예정
        $0.layer.cornerRadius = 10
    }
    
    private let container = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 8
        $0.distribution = .fill
        $0.alignment = .fill
    }
    
    // Row: 시작
    private let startRow = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.spacing = 4
        $0.distribution = .fill
        $0.isLayoutMarginsRelativeArrangement = true
        $0.layoutMargins = .zero
    }

    private let startLabel = UILabel().then {
        $0.text = "시작 시간"
        $0.font = .font17Regular
        $0.textColor = .neutral50
        $0.setContentHuggingPriority(.required, for: .horizontal)
    }
    
    private let startRowSpacer = UIView()
    private let startDateButton = UIButton.makeDateButton()
    private let startTimeButton = UIButton.makeDateButton()
    
    private let startDatePicker = UIDatePicker().then {
        $0.datePickerMode = .date
        $0.preferredDatePickerStyle = .inline
        $0.locale = Locale(identifier: "ko_KR")
        $0.calendar = Calendar(identifier: .gregorian)
        $0.applyYearRange(minYear: 1900, maxYear: 2500)
        $0.isHidden = true
    }

    private let startTimePicker = UIDatePicker().then {
        $0.datePickerMode = .time
        $0.preferredDatePickerStyle = .wheels
        $0.minuteInterval = 5
        $0.locale = Locale(identifier: "ko_KR")
        $0.calendar = Calendar(identifier: .gregorian)
        $0.isHidden = true
    }
    
    private let containerSpacer = UIView().then {
        $0.backgroundColor = .systemGray3
    }
    
    // Row: 종료
    private let endRow = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.spacing = 4
        $0.distribution = .fill
        $0.isLayoutMarginsRelativeArrangement = true
        $0.layoutMargins = .zero
    }

    private let endLabel = UILabel().then {
        $0.text = "종료 시간"
        $0.font = .font17Regular
        $0.textColor = .neutral50
        $0.setContentHuggingPriority(.required, for: .horizontal)
    }

    private let endRowSpacer = UIView()
    private let endDateButton = UIButton.makeDateButton()
    private let endTimeButton = UIButton.makeDateButton()
    
    private let endDatePicker = UIDatePicker().then {
        $0.datePickerMode = .date
        $0.preferredDatePickerStyle = .inline
        $0.locale = Locale(identifier: "ko_KR")
        $0.calendar = Calendar(identifier: .gregorian)
        $0.applyYearRange(minYear: 1900, maxYear: 2500)
        $0.isHidden = true
    }

    private let endTimePicker = UIDatePicker().then {
        $0.datePickerMode = .time
        $0.preferredDatePickerStyle = .wheels
        $0.minuteInterval = 5
        $0.locale = Locale(identifier: "ko_KR")
        $0.calendar = Calendar(identifier: .gregorian)
        $0.isHidden = true
    }
    
    private enum ActivePanel {
        case none, startDate, startTime, endDate, endTime
    }

    private var activePanel: ActivePanel = .none {
        didSet { updatePanelVisibility(animated: true) }
    }
    
    private let disposeBag = DisposeBag()
    
    // MARK: 초기화

    override init(frame: CGRect) {
        // 기본값: 시작=지금(분,초 0으로), 종료=시작+1시간
        let now = DateRangeFieldContainerView.roundToHour(Date())
        self.startDate = now
        self.endDate = Calendar.current.date(byAdding: .hour, value: 1, to: now) ?? now.addingTimeInterval(3600)
        
        super.init(frame: frame)
        setupUI()
        bind()
        syncStartUI()
        syncEndUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(sectionHeader)
        sectionHeader.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        addSubview(cardView)
        cardView.snp.makeConstraints {
            $0.top.equalTo(sectionHeader.snp.bottom).offset(8)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        cardView.addSubview(container)
        container.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(10)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        // 상단 행 (시작 시간)
        container.addArrangedSubview(startRow)
        startRow.snp.makeConstraints { $0.height.equalTo(25.5) }
        startRow.addArrangedSubview(startLabel)
        startRow.addArrangedSubview(startRowSpacer)
        startRow.addArrangedSubview(startDateButton)
        startRow.addArrangedSubview(startTimeButton)
        
        container.addArrangedSubview(startDatePicker)
        container.addArrangedSubview(startTimePicker)
        
        // 중간 스페이서
        container.addArrangedSubview(containerSpacer)
        containerSpacer.snp.makeConstraints { $0.height.equalTo(1) }
        
        // 하단 행 (종료 시간)
        container.addArrangedSubview(endRow)
        endRow.snp.makeConstraints { $0.height.equalTo(25.5) }
        endRow.addArrangedSubview(endLabel)
        endRow.addArrangedSubview(endRowSpacer)
        endRow.addArrangedSubview(endDateButton)
        endRow.addArrangedSubview(endTimeButton)
        
        container.addArrangedSubview(endDatePicker)
        container.addArrangedSubview(endTimePicker)
    }
    
    private func bind() {
        // 버튼 탭 처리
        startDateButton.rx.tap
            .bind { [weak self] in self?.toggle(panel: .startDate) }
            .disposed(by: disposeBag)
        
        startTimeButton.rx.tap
            .bind { [weak self] in self?.toggle(panel: .startTime) }
            .disposed(by: disposeBag)
        
        endDateButton.rx.tap
            .bind { [weak self] in self?.toggle(panel: .endDate) }
            .disposed(by: disposeBag)
        
        endTimeButton.rx.tap
            .bind { [weak self] in self?.toggle(panel: .endTime) }
            .disposed(by: disposeBag)
        
        // 피커 값 변경
        startDatePicker.rx.controlEvent(.valueChanged)
            .bind { [weak self] in
                guard let self else { return }
                let newDate = merge(date: startDatePicker.date, timeFrom: startDate)
                self.setStart(newDate, propagate: true)
            }.disposed(by: disposeBag)
        
        startTimePicker.rx.controlEvent(.valueChanged)
            .bind { [weak self] in
                guard let self else { return }
                let newDate = merge(date: startDate, timeFrom: startTimePicker.date)
                self.setStart(newDate, propagate: true)
            }.disposed(by: disposeBag)
        
        endDatePicker.rx.controlEvent(.valueChanged)
            .bind { [weak self] in
                guard let self else { return }
                let newDate = merge(date: endDatePicker.date, timeFrom: endDate)
                self.setEnd(newDate, propagate: true)
            }.disposed(by: disposeBag)
        
        endTimePicker.rx.controlEvent(.valueChanged)
            .bind { [weak self] in
                guard let self else { return }
                let newDate = merge(date: endDate, timeFrom: endTimePicker.date)
                self.setEnd(newDate, propagate: true)
            }.disposed(by: disposeBag)
    }
    
    // MARK: 액션들
    
    /// 날짜 패널 <-> 시간 패널 토글 하는 함수
    /// 현재 활성화된 패널이 새로 토글하려는 패널과 동일하면 현재 열려 있는 패널을 닫음, 아니면 새로운 패널을 활성화하고 표시함
    private func toggle(panel: ActivePanel) {
        activePanel = (activePanel == panel) ? .none : panel
    }
    
    /// 날짜/시간 패널의 보여짐/숨겨짐을 업데이트하는 함수
    private func updatePanelVisibility(animated: Bool) {
        // 버튼과 피커, 패널 하나로 묶어 관리
        let panelItems: [(button: UIButton, picker: UIView, panel: ActivePanel)] = [
            (startDateButton, startDatePicker, .startDate),
            (startTimeButton, startTimePicker, .startTime),
            (endDateButton, endDatePicker, .endDate),
            (endTimeButton, endTimePicker, .endTime)
        ]

        let changes = {
            for item in panelItems {
                let shouldBeHidden = (self.activePanel != item.panel)
                
                item.button.isSelected = !shouldBeHidden // 버튼의 선택 상태를 활성 패널과 일치시킴
                
                // `isHidden` 상태가 변경될 때만 값을 할당하여 레이아웃 혼란을 방지
                if item.picker.isHidden != shouldBeHidden {
                    item.picker.isHidden = shouldBeHidden
                }
            }
            
            self.layoutIfNeeded()
        }

        // 애니메이션 여부에 따라 UI 업데이트 실행
        guard animated else { changes(); return }
        UIView.animate(withDuration: 0.25, animations: changes)
    }
    
    // MARK: 외부/내부 값 세터

    func setStart(_ date: Date, propagate: Bool) {
        startDate = date
        // 종료 시간을 시작 시간보다 앞으로 두려고 하면 시작 시간 한시간 뒤로 강제함
        if endDate < startDate {
            endDate = Calendar.current.date(byAdding: .hour, value: 1, to: startDate) ?? startDate.addingTimeInterval(3600)
        }
        if propagate { startDateChanged.accept(startDate) }
    }
    
    func setEnd(_ date: Date, propagate: Bool) {
        let final = max(date, startDate)
        endDate = final
        if propagate { endDateChanged.accept(endDate) }
    }
    
    // MARK: UI 동기화

    private func syncStartUI() {
        update(button: startDateButton, with: DateFormatter.toDateString(startDate))
        update(button: startTimeButton, with: DateFormatter.toTimeString(startDate))
        startDatePicker.setDate(startDate, animated: false)
        startTimePicker.setDate(startDate, animated: false)
        // 시작 시간이 바뀌면 종료 시간도 갱신하도록
        endDatePicker.minimumDate = startOfDay(for: startDate)
    }

    private func syncEndUI() {
        update(button: endDateButton, with: DateFormatter.toDateString(endDate))
        update(button: endTimeButton, with: DateFormatter.toTimeString(endDate))
        endDatePicker.minimumDate = startOfDay(for: startDate)
        endDatePicker.setDate(endDate, animated: false)
        endTimePicker.setDate(endDate, animated: false)
    }
    
    // MARK: 유틸

    // 버튼 업데이트
    private func update(button: UIButton, with text: String) {
        var config = button.configuration ?? .bordered()
        config.title = text
        button.configuration = config
    }
    
    /// 따로 받은 날짜와 시간을 합쳐주는 함수
    private func merge(date: Date, timeFrom ref: Date) -> Date {
        let calendar = Calendar.current
        let day = calendar.dateComponents([.year, .month, .day], from: date)
        let time = calendar.dateComponents([.hour, .minute, .second], from: ref)
        var components = DateComponents()
        components.year = day.year; components.month = day.month; components.day = day.day
        components.hour = time.hour; components.minute = time.minute
        components.second = 0
        return calendar.date(from: components) ?? date
    }
    
    private func startOfDay(for date: Date) -> Date {
        Calendar.current.startOfDay(for: date)
    }
    
    /// 시간을 받고 분, 초 날려주는 함수
    static func roundToHour(_ date: Date) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        components.minute = 0
        components.second = 0
        return calendar.date(from: components) ?? date
    }
}

#Preview {
    DateRangeFieldContainerView()
}
