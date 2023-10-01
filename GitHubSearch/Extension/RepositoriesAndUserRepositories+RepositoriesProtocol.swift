//
//  RepositoriesAndUserRepositories+RepositoriesProtocol.swift
//  GitHubSearch
//
//  Created by Yevhen Mekhedov on 11.02.2020.
//  Copyright © 2020 Yevhen Mekhedov. All rights reserved.
//

import Foundation
import CoreData

extension Repositories: RepositoriesProtocol {
    class var sortingKeys: [String] {
        ["stars"]
    }

    static var sectionNameKeyPath: String?

    class var cacheName: String? {
        "PreviousSearchRepositories"
    }

    //static var predicate: NSPredicate?
}

extension UserRepositories {
    @objc override class var sortingKeys: [String] {
        ["stars"]
    }

    @objc override class var cacheName: String? {
        "UserRepositoriesCache"
    }
}
