
import ReactorKit
import RxFlow
import RxRelay
import RxSwift

class BaseReactor<Action, Mutation, State>: Reactor, Stepper {
    let initialState: State
    let steps = PublishRelay<Step>()

    init(initialState: State) {
        self.initialState = initialState
    }

    func mutate(action _: Action) -> Observable<Mutation> {
        // Swift에는 abstract가 없어서 추상 메서드를 표현하기 위해 fatalError를 사용
        fatalError("muatate(action:) must be overridden")
    }

    func reduce(state _: State, mutation _: Mutation) -> State {
        fatalError("reduce(state:mutation:) must be overridden")
    }

    // state를 변경하는 행위는 이 transform을 타게되서 .observe를 일일이 넣어주지 않아도 된다.
    func transform(state: Observable<State>) -> Observable<State> {
        return state.observe(on: MainScheduler.instance)
    }
}
