//
//  GHUserRepositoriesContainer.swift
//  GitHubSearch
//
//  Created by Yevhen Mekhedov on 31.01.2020.
//  Copyright © 2020 Yevhen Mekhedov. All rights reserved.
//

import Foundation

struct GHUserRepositoriesContainer: GHResponse {
    typealias ContainerType = [GHItemImpl]

    private(set) var containerValue: ContainerType

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        containerValue = try container.decode(ContainerType.self)
    }
}
