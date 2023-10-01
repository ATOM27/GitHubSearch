//
//  GHRequest.swift
//  GitHubSearch
//
//  Created by Yevhen Mekhedov on 22.01.2020.
//  Copyright © 2020 Yevhen Mekhedov. All rights reserved.
//

import Foundation

enum GHRequest {
    enum Search {
        case searchByRepositoryName
    }

    enum Repositories {
        case byUserName(userName: String)
    }
}

extension GHRequest.Search: GHEndPointRequest {
    var endPoint: String {
        switch self {
        case .searchByRepositoryName:
            return "search/repositories"
        }
    }
}

extension GHRequest.Repositories: GHEndPointRequest {
    var endPoint: String {
        switch self {
        case .byUserName(let userName):
            return "users/\(userName)/repos"
        }
    }
}
