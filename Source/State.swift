//
//  State.swift
//  Swifty_Flux
//
//  Created by Takuya Osawa on 2019/11/15.
//  Copyright © 2019 Takuya Osawa. All rights reserved.
//

import Foundation

public protocol State {
    associatedtype ActionType: Swifty_Flux.Action
    func reduce(action: ActionType)
}
