//
//  GHNetworkImpl.swift
//  GitHubSearch
//
//  Created by Yevhen Mekhedov on 22.01.2020.
//  Copyright © 2020 Yevhen Mekhedov. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireNetworkActivityIndicator

public class GHNetworkImpl: GHNetwork {
    private(set) public var search: GHSearchService
    private(set) public var repositories: GHRepositoriesService

    private var APIURLLink = "https://api.github.com/"
    private var headers: [String: String] = [:]

    public init() {
        Alamofire.SessionManager.default.startRequestsImmediately = false
        NetworkActivityIndicatorManager.shared.isEnabled = true
        search = GHSearchServiceImpl(apiURL: APIURLLink, headers: ["Accept": "application/vnd.github.v3+json"])
        repositories = GHRepositoriesServiceImpl(apiURL: APIURLLink, headers: ["Accept": "application/vnd.github.nebula-preview+json"])
    }
}
