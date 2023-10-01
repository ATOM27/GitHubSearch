//
//  GHItemContainer.swift
//  GitHubSearch
//
//  Created by Yevhen Mekhedov on 22.01.2020.
//  Copyright © 2020 Yevhen Mekhedov. All rights reserved.
//

import Foundation

struct GHItemContainer: GHResponse {
    typealias ContainerType = [GHItemImpl]

    private(set) var containerValue: ContainerType

    enum CodingKeys: String, CodingKey {
        case items
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        containerValue = try container.decode(ContainerType.self, forKey: .items)
    }
}
