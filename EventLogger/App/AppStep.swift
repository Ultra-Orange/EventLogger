//
//  AppStep.swift
//  RxFlowPractice
//
//  Created by Yoon on 8/19/25.
//

import RxFlow

enum AppStep: Step {
    case eventList
    case eventDetail(EventItem)
    case createSchedule
    case updateSchedule(EventItem)
    case locationSearch(String)
}
