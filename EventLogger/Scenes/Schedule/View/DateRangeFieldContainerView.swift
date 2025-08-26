//
//  DateRangeFieldContainerView.swift
//  EventLogger
//
//  Created by 김우성 on 8/26/25.
//

import SnapKit
import Then
import UIKit
import RxSwift
import RxCocoa

final class DateRangeFieldContainerView: UIView {
    
    // MARK: API
    /// 외부에서 읽기/설정 가능한 시작/종료 날짜 (설정 시 UI 동기화)
    var startDate: Date {
        didSet { applyStart(date: startDate, propagate: false) }
    }
    var endDate: Date {
        didSet { applyEnd(date: endDate, propagate: false) }
    }
    
    /// 값 변경을 외부로 내보내기
    let startDateChanged = PublishRelay<Date>()
    let endDateChanged = PublishRelay<Date>()
    
    // MARK: UI
    private let titleLabel = UILabel().then {
        $0.text = "날짜"
        $0.font = .font13Regular
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
        $0.spacing = 8
        $0.alignment = .center
        $0.distribution = .fill
    }
    
    private let startLabel = UILabel().then {
        $0.text = "시작"
        $0.font = .font13Regular
        $0.textColor = .secondaryLabel
        $0.setContentHuggingPriority(.required, for: .horizontal)
    }
    private let startDateButton = UIButton(type: .system).then {
        $0.configuration = .bordered()
        $0.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
    }
    private let startTimeButton = UIButton(type: .system).then {
        $0.configuration = .bordered()
        $0.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
    }
    
    // Row: 종료
    private let endRow = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.alignment = .center
        $0.distribution = .fill
    }
    
    private let endLabel = UILabel().then {
        $0.text = "종료"
        $0.font = .font13Regular
        $0.textColor = .secondaryLabel
        $0.setContentHuggingPriority(.required, for: .horizontal)
    }
    private let endDateButton = UIButton(type: .system).then {
        $0.configuration = .bordered()
        $0.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
    }
    private let endTimeButton = UIButton(type: .system).then {
        $0.configuration = .bordered()
        $0.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
    }
    
    // 펼침 영역 (한 번에 하나만 보이게)
    private let pickerContainer = UIView().then {
        $0.clipsToBounds = true
    }
    private let datePicker = UIDatePicker().then {
        $0.datePickerMode = .date
        $0.preferredDatePickerStyle = .inline
        $0.locale = Locale(identifier: "ko_KR")
        $0.calendar = Calendar(identifier: .gregorian)
    }
    private let timePicker = UIDatePicker().then {
        $0.datePickerMode = .time
        $0.preferredDatePickerStyle = .wheels
        $0.minuteInterval = 5
        $0.locale = Locale(identifier: "ko_KR")
        $0.calendar = Calendar(identifier: .gregorian)
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
        
        applyStart(date: startDate, propagate: false)
        applyEnd(date: endDate, propagate: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(titleLabel)
        addSubview(container)
        addSubview(pickerContainer)
        
        container.addArrangedSubview(startRow)
        container.addArrangedSubview(endRow)
        
        startRow.addArrangedSubview(startLabel)
        startRow.addArrangedSubview(startDateButton)
        startRow.addArrangedSubview(startTimeButton)
        
        endRow.addArrangedSubview(endLabel)
        endRow.addArrangedSubview(endDateButton)
        endRow.addArrangedSubview(endTimeButton)
        
        // 버튼 라벨 폰트 통일
        [startDateButton, startTimeButton, endDateButton, endTimeButton].forEach {
            $0.configuration?.background.backgroundColor = .clear
            $0.configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var out = incoming
                out.font = .font16Regular
                return out
            }
        }
        
        pickerContainer.addSubview(datePicker)
        pickerContainer.addSubview(timePicker)
        
        titleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
        }
        container.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
        }
        startRow.snp.makeConstraints {
            $0.height.equalTo(44)
        }
        endRow.snp.makeConstraints {
            $0.height.equalTo(44)
        }
        // label 고정폭 최소화
        startLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        endLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        pickerContainer.snp.makeConstraints {
            $0.top.equalTo(container.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        datePicker.snp.makeConstraints { $0.edges.equalToSuperview() }
        timePicker.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        // 시작 시에는 안보이게
        datePicker.isHidden = true
        timePicker.isHidden = true
        pickerContainer.isHidden = true
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
        datePicker.rx.controlEvent(.valueChanged)
            .bind { [weak self] in self?.handleDatePicked() }
            .disposed(by: disposeBag)
        
        timePicker.rx.controlEvent(.valueChanged)
            .bind { [weak self] in self?.handleTimePicked() }
            .disposed(by: disposeBag)
    }
    
    // MARK: 액션들
    
    /// 날짜 패널 <-> 시간 패널 토글 하는 함수
    private func toggle(panel: ActivePanel) {
        
    }
    
    /// 날짜 패널 <-> 시간 패널 보여지는 것 업데이트하는 함수
    private func updatePanelVisibility(animated: Bool) {
        
    }
    
    /// 날짜 고른 거 다루는 함수
    private func handleDatePicked() {
        
    }
    
    /// 시간 고른 거 다루는 함수
    private func handleTimePicked() {
        
    }
    
    // MARK: 적용하고 동기화
    private func applyStart(date: Date, propagate: Bool) {
        
    }
    
    private func applyEnd(date: Date, propagate: Bool) {
        
    }
    
    private func update(button: UIButton, withDateText text: String) {
        
    }
    private func update(button: UIButton, withTimeText text: String) {
        
    }
    
    /// 따로 받은 날짜와 시간을 합쳐주는 함수
    private func merge(date: Date, timeFrom ref: Date) -> Date {
        
        return Date()
    }
    
    private func startOfDay(for date: Date) -> Date {
        
        return Date()
    }
    
    /// 시간을 받고 분, 초 날려주는 함수
    static func roundToHour(_ date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        var new = components
        new.minute = 0
        new.second = 0
        return calendar.date(from: new) ?? date
    }
}
