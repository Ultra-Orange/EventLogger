# EventLogger

![iOS](https://img.shields.io/badge/iOS-17%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5-orange)
![Xcode](https://img.shields.io/badge/Xcode-16.4-lightgrey)
![RxSwift](https://img.shields.io/badge/RxSwift-6-purple)
![ReactorKit](https://img.shields.io/badge/ReactorKit-yellowgreen)
![SwiftData](https://img.shields.io/badge/SwiftData-red)
![CloudKit](https://img.shields.io/badge/CloudKit-skyblue)
![SnapKit](https://img.shields.io/badge/SnapKit-brightgreen)

## 프로젝트 개요
  - 나만의 이벤트 일정을 아카이빙 & 스케쥴링하는 앱

## 주요 기능
 - 이벤트 일정 등록/편집
 - 이벤트 일정 확인(목록, 푸시알림)
 - 참가 이벤트 통계
  
## 기술적 의사결정

### 사용 아키텍쳐 및 라이브러리
```
iOS: 17.0+
Architecture: MVVM-C + ReactorKit
Reactive: RxSwift, RxCocoa, RxRelay, RxFlow, RxGesture
UI: UIKit, SwiftUI, SnapKit, HostingView, Then, WSTagsField
Data: SwiftData, CloudKit
Etc: swift-dependencies
```

- SwiftData 는 iOS 17이상만 지원하는데 25년 6월 기준 iOS 점유율 조사 결과 iOS 17 이상 점유율이 96%이므로 iOS17+ 빌드타겟이 문제가 없다고 판단 (출처 - https://developer.apple.com/support/app-store/)
- 단방향 데이터 통신 보장하고 화면 이동관리에 용이한 `MVVM-C` 패턴 채택
- 리액티브 프로그래밍을 돕는 `Rx`관련 라이브러리 도입
- `UIKit` 을 메인으로 일부 요소에 `SwiftUI` 를 혼용
- `CloudKit` 으로 데이터 동기화 **보장**
- `swift-dependencies` 로 의존성 주입관리

### 개발환경
```
macOS Sequia 15.5
Xcode 16.4
Swift 5 
Swift Package Manager
```

### 사용한 오픈소스 라이브러리

본 프로젝트는 다음 오픈소스 라이브러리를 사용하였습니다.  
모든 라이브러리는 MIT License 하에 배포됩니다.

- RxSwift / RxCocoa / RxRelay
- RxFlow
- RxGesture
- ReactorKit
- SnapKit
- Then
- WSTagsField
- swift-dependencies

## 화면 설계/흐름
TODO

## 데모 자료
TODO

## 프로젝트 구조
```
📁 PuppyBox
├── 📁 App                  // 앱, 화면 진입점
├── 📁 Base                 // 베이스 리액터, VC
├── 📁 Extensions           // 각종 확장
├── 📁 Model                // 데이터 모델
│   └── 📁 SwiftDataModel            // 스위프트 데이터 모델
├── 📁 Resources            // 앱 내부 사용 리소스
├── 📁 Scenes               // 화면별 폴더 구조
│   ├── 📁 EventDetail      // 이벤트 상세화면
│   ├── 📁 EventList        // 이벤트 목록화면
│   ├── 📁 Schedule         // 이벤트 등록/수정 화면
│   ├── 📁 Settings         // 설정화면
│   ├── 📁 Statistics       // 통계화면
└── 📁 Util                // 유틸리티
```

팀원 정보

| 이름 | 역할 | 담당 기능 |
|------|---|---|
| 윤승렬 | iOS개발 | 이벤트 등록/수정, 개별 이벤트 상세, 길 찾기, 설정화면, 스위프트 데이터, 클라우드킷, 공유기능 |
| 김우성 | iOS개발 | 이벤트 등록/수정, 권한설정, 전체 이벤트 목록, 캘린더 자동 등록, 통계 화면, 공용 UI |
| 원지영 | UI/UX | 와이어프레임, 화면 디자인, UX설계 |

## 라이센스 정보

본 프로젝트는 교육 및 포트폴리오 목적의 비상업적 용도로 제작되었습니다.

작성자 동의 없이 소스코드, 디자인, 또는 결과물을 **상업적으로 이용하거나 재배포할 수 없습니다**.

프로젝트에 포함된 모든 코드와 자료는 **직접 구현 또는 학습 목적의 참고 기반**으로 작성되었으며,

외부 오픈소스 또는 디자인 참고 요소가 포함된 경우, 해당 출처를 함께 명시하였습니다.

본 프로젝트가 궁금하시거나 활용을 원하시는 경우, 아래 연락처 중 하나로 문의해주세요.

> 이메일: 
