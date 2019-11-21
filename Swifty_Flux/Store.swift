//
//  Store.swift
//  Swifty_Flux
//
//  Created by Takuya Osawa on 2019/11/15.
//  Copyright © 2019 Takuya Osawa. All rights reserved.
//

import Foundation

open class Store<StateType: Swifty_Flux.State> {
    // MARK: - public
    public let state: StateType
    public func subscribe() {
        if let _registerKey = registerKey {
            dispatcher.unRegister(key: _registerKey)
        }
        
        registerKey = dispatcher.register(for: Store<StateType>.self) { [weak self] (action) in
            guard let _self = self else { return }
            _self.state.reduce(action: action)
            _self.lastDispatchedaAtionHandler?(_self.state, action)
        }
    }
    
    public func unSubscribe() {
        guard let _registerKey = registerKey else {
            return
        }
        dispatcher.unRegister(key: _registerKey)
    }
    
    public func register(middlewares: [MiddlewareType]) {
        self.middlewares.append(contentsOf: middlewares)
        middlewares.forEach {( $0.observe(store: self) )}
    }
    
    public var lastDispatchedaAtionHandler: ((_ stateType: StateType, _ lastDispatchedaAtion: StateType.ActionType?) -> Void)?
    
    // MARK: - initializer
    public init(state: StateType, dispatcher: Dispatcher<StateType.ActionType> = Dispatcher<StateType.ActionType>.shared) {
        self.dispatcher = dispatcher
        self.state = state
    }
    
    // MARK: - private
    private var registerKey: String?
    private var middlewares: [MiddlewareType] = []
    private let dispatcher: Dispatcher<StateType.ActionType>
}
