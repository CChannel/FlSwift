//
//  InterfaceController.swift
//  Swifty_FluxExample_Watch Extension
//
//  Created by Takuya Osawa on 2019/12/02.
//  Copyright © 2019 Takuya Osawa. All rights reserved.
//

import WatchKit
import Foundation
import Swifty_Flux
import RxSwift
import RxCocoa

class InterfaceController: WKInterfaceController {
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        store.state.number
            .asObservable()
            .map({ String($0) })
            .subscribe(onNext: { [weak self] (text) in
                self?.label.setText(text)
            }).disposed(by: disposeBag)
    }
    
    @IBAction private func plusButtonTapped(_ sender: Any) {
        NumberActionCreator.shared.dispatcher.dispatch(.increase(1))
    }
    
    @IBAction private func  minusButtonTapped(_ sender: Any) {
        NumberActionCreator.shared.dispatcher.dispatch(.decrease(1))
    }
    
    override func willActivate() {
        super.willActivate()
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }
    
    @IBOutlet private weak var label: WKInterfaceLabel!
    @IBOutlet private weak var plusButton: WKInterfaceButton!
    @IBOutlet private weak var minusButton: WKInterfaceButton!
    private let disposeBag = DisposeBag()
    private lazy var store: Store<NumberState> = {
        let state = NumberState()
        let store = Store(state: state)
        store.subscribe()
        return store
    }()
}

enum NumberAction: Action {
    case increase(Int)
    case decrease(Int)
}

class NumberActionCreator {
    static let shared = NumberActionCreator()
    private init() {}
    let dispatcher = Swifty_Flux.Dispatcher<NumberAction>.shared
}

class NumberState: State {
    typealias ActionType = NumberAction
    
    func reduce(action: NumberAction) {
        switch action {
        case .increase(let value):
            number.accept(number.value + value)
        case .decrease(let value):
            number.accept(number.value - value)
        }
    }
    
    var number =  BehaviorRelay<Int>(value: 0)
}

