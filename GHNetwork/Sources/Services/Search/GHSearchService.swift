//
//  GHSearchService.swift
//  GitHubSearch
//
//  Created by Yevhen Mekhedov on 22.01.2020.
//  Copyright © 2020 Yevhen Mekhedov. All rights reserved.
//

import Foundation

public protocol GHSearchService {
    // swiftlint:disable:next function_parameter_count
    func find(name: String,
              sort: SearchRepoSort,
              page: Int,
              itemsInPage: Int,
              cancelPrevious: Bool,
              completion: @escaping Completion<[GHItem]>)
}
