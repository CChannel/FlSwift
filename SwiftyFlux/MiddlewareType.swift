//
//  MiddlewareType.swift
//  SwiftyFlux
//
//  Created by Takuya Osawa on 2019/11/15.
//  Copyright © 2019 Takuya Osawa. All rights reserved.
//

import Foundation

public protocol MiddlewareType {
    func observe<StateType: SwiftyFlux.State>(store: Store<StateType>)
}
