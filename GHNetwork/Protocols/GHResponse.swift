//
//  GHResponse.swift
//  GitHubSearch
//
//  Created by Yevhen Mekhedov on 22.01.2020.
//  Copyright © 2020 Yevhen Mekhedov. All rights reserved.
//

import Foundation

protocol GHResponse: Decodable {

    associatedtype ContainerType: Decodable

    var containerValue: ContainerType { get }
}
