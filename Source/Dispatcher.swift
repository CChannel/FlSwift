//
//  Dispatcher.swift
//  FlSwift
//
//  Created by Takuya Osawa on 2019/11/15.
//  Copyright © 2019 Takuya Osawa. All rights reserved.
//

import Foundation

//https://stackoverflow.com/questions/37963327/what-is-a-good-alternative-for-static-stored-properties-of-generic-types-in-swif
private class GenericStatic {
    private static var singletons: [String: Any] = [:]
    
    static func singleton<GenericInstance, SingletonType>(for generic: GenericInstance, _ newInstance: () -> SingletonType) -> SingletonType {
        let key = "\(String(describing: GenericInstance.self)).\(String(describing: SingletonType.self))"
        if singletons[key] == nil {
            singletons[key] = newInstance()
        }
        return singletons[key] as! SingletonType
    }
}

public final class Dispatcher<A: FlSwift.Action> {
    // MARK: - public
    public static var shared: Dispatcher<A> {
        return GenericStatic.singleton(for: self) {
            return Dispatcher<A>()
        }
    }
    
    // MARK: - initializer
    private init() {}
    private let locker = NSRecursiveLock()
    private var callBackDictionary: [String: (A) -> Void] = [:]
    
    public func register<T>(for type: T.Type, callback: @escaping (A) -> Void) -> String {
        locker.lock()
        defer { locker.unlock() }
        
        let key = String(describing: type) + UUID().uuidString
        callBackDictionary[key] = callback
        return key
    }
    
    public func unRegister(key: String) {
        locker.lock()
        defer { locker.unlock() }
        
        callBackDictionary.removeValue(forKey: key)
    }
    
    public func dispatch(_ action: A) {
        locker.lock()
        defer { locker.unlock() }
        
        callBackDictionary.forEach { (_, callBack) in
            callBack(action)
        }
    }
}
