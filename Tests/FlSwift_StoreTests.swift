//
//  FlSwift_StoreTests.swift
//  FlSwiftTests
//
//  Created by Takuya Osawa on 2019/11/15.
//  Copyright © 2019 Takuya Osawa. All rights reserved.
//

import XCTest
@testable import FlSwift

class FlSwift_StoreTests: XCTestCase {
    private enum TestAction: Action {
        case increase(Int)
        case decrease(Int)
    }
    
    private class TestActionCreator {
        static let shared = TestActionCreator()
        private init() {}
        let dispatcher = Dispatcher<TestAction>.shared
    }
    
    private class TestState: State {
        typealias ActionType = TestAction
        func reduce(action: FlSwift_StoreTests.TestAction) {
            switch action {
            case .increase(let _value):
                self.value += _value
            case .decrease(let _value):
                self.value -= _value
            }
        }
        
        var value = 0
    }
    
    private var store: Store<TestState>!
    override func setUp() {
        let state = TestState()
        store = Store<TestState>(state: state)
        store.subscribe()
    }

    func test_Store_value() {
        TestActionCreator.shared.dispatcher.dispatch(.increase(1))
        XCTAssertEqual(store.state.value, 1)
        
        TestActionCreator.shared.dispatcher.dispatch(.decrease(2))
        XCTAssertEqual(store.state.value, -1)
    }
}
