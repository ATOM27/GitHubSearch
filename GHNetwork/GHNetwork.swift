//
//  GHNetwork.swift
//  GitHubSearch
//
//  Created by Yevhen Mekhedov on 22.01.2020.
//  Copyright © 2020 Yevhen Mekhedov. All rights reserved.
//

import UIKit

//public let NetworkService: GHNetwork = GHNetworkImpl()
public typealias Completion<T> = (GHResult<T>) -> Void

public protocol GHNetwork {
    var search: GHSearchService { get }
    var repositories: GHRepositoriesService { get }
}
