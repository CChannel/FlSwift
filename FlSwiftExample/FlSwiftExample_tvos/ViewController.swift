//
//  ViewController.swift
//  FlSwiftExample_tvos
//
//  Created by Takuya Osawa on 2019/12/02.
//  Copyright © 2019 Takuya Osawa. All rights reserved.
//

import UIKit
import FlSwift
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        store.state.number
            .asObservable()
            .map({ String($0) })
            .bind(to: label.rx.text)
            .disposed(by: disposeBag)
    }
    
    @IBAction private func plusButtonTapped(_ sender: Any) {
        NumberActionCreator.shared.dispatcher.dispatch(.increase(1))
    }
    
    @IBAction private func  minusButtonTapped(_ sender: Any) {
        NumberActionCreator.shared.dispatcher.dispatch(.decrease(1))
    }
    // MARK: - private
    @IBOutlet private weak var label: UILabel!
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
    let dispatcher = FlSwift.Dispatcher<NumberAction>.shared
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
