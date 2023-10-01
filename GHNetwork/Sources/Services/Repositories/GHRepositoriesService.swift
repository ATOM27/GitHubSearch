//
//  GHRepositoriesService.swift
//  GitHubSearch
//
//  Created by Yevhen Mekhedov on 31.01.2020.
//  Copyright © 2020 Yevhen Mekhedov. All rights reserved.
//

import Foundation

public protocol GHRepositoriesService {
    func getUserRepositories(userName: String, page: Int, itemsInPage: Int,
                             cancelPrevious: Bool, completion: @escaping Completion<[GHItem]>)
}
