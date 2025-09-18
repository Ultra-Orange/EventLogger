//
//  AppStep.swift
//  RxFlowPractice
//
//  Created by Yoon on 8/19/25.
//

import RxFlow

enum AppStep: Step {
    case splash
    case eventList
    case eventDetail(EventItem)
    case createSchedule
    case updateSchedule(EventItem)
    case locationSearch(String)
    case settings
    case categoryList
    case createCategory
    case updateCategory(CategoryItem)
    case backToCategoryList
    case statistics
    case queryToGoogleMap(String)
}
