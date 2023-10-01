//
//  RepositoriesProtocol.swift
//  GitHubSearch
//
//  Created by Yevhen Mekhedov on 06.02.2020.
//  Copyright © 2020 Yevhen Mekhedov. All rights reserved.
//

import Foundation
import CoreData
/// This protocol describes which fields should have entities with repositories information
protocol RepositoriesProtocol: BaseEntityProtocol {
    ///Entity must have a `name` property
    var name: String? { get set }

    ///Entity must have a `stars` property
    var stars: Int32 { get set }
}
