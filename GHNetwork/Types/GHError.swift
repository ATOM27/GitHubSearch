//
//  GHError.swift
//  GitHubSearch
//
//  Created by Yevhen Mekhedov on 22.01.2020.
//  Copyright © 2020 Yevhen Mekhedov. All rights reserved.
//

import Foundation

public enum GHError: Error {
    case defaultError
    case wrongProtocol(protocolName: String)

    var description: String {
        switch self {
        case .defaultError:
            return "Some error occured"
        case .wrongProtocol(let protocolName):
            return "The data retrieved from server do not conform to given protocol: \(protocolName)"
        }
    }
}
