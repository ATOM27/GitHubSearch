//
//  GHResult.swift
//  GitHubSearch
//
//  Created by Yevhen Mekhedov on 22.01.2020.
//  Copyright © 2020 Yevhen Mekhedov. All rights reserved.
//

import Foundation

public enum GHResult<Value> {

    // MARK: -
    // MARK: Cases

    case success(Value)
    case failure(String)

    // MARK: -
    // MARK: Properties

    public var value: Value? {
        return analisis(success: identify, failure: {_ in nil })
    }

    public var error: String? {
        return analisis(success: {_ in nil }, failure: identify)
    }

    // MARK: -
    // MARK: Init

    public init (value: Value?, error: String?) {
        if let error = error {
            self = .failure(error)
        } else {
            self = .success(value!)
        }
    }

    private func analisis<RT>(success: (Value) -> RT,
                              failure: (String) -> RT) -> RT {
        switch self {
        case let .success(wrapped): return success(wrapped)
        case let .failure(wrapped): return failure(wrapped)
        }
    }

    private func identify<T>(_ value: T) -> T {
        return value
    }
}
