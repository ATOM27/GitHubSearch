//
//  GHItemImpl.swift
//  GitHubSearch
//
//  Created by Yevhen Mekhedov on 22.01.2020.
//  Copyright © 2020 Yevhen Mekhedov. All rights reserved.
//

import Foundation

class GHItemImpl: NSObject, GHItem, Decodable {
//swiftlint:disable:next identifier_name
    @objc private(set) var id: Int
    @objc private(set) var name: String
    @objc private(set) var fullName: String
    @objc private(set) var ownerName: String
    @objc private(set) var stars: Int

    private enum CodingKeys: String, CodingKey {
        //swiftlint:disable:next identifier_name
        case id         = "id"
        case name       = "name"
        case fullName   = "full_name"
        case stars      = "stargazers_count"
        case owner      = "owner"
    }

    private enum NestedCodingKeys: String, CodingKey {
        case login
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.fullName = try container.decode(String.self, forKey: .fullName)
        self.stars = try container.decode(Int.self, forKey: .stars)
        let nestedContainer = try container.nestedContainer(keyedBy: NestedCodingKeys.self, forKey: .owner)
        self.ownerName = try nestedContainer.decode(String.self, forKey: .login)
    }
}
