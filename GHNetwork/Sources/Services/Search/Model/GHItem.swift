//
//  GHItem.swift
//  GitHubSearch
//
//  Created by Yevhen Mekhedov on 22.01.2020.
//  Copyright © 2020 Yevhen Mekhedov. All rights reserved.
//

import Foundation

@objc public protocol GHItem: NSObjectProtocol {
    //swiftlint:disable:next identifier_name
    @objc var id: Int { get }
    @objc var name: String { get }
    @objc var fullName: String { get }
    @objc var ownerName: String { get }
    @objc var stars: Int { get }
}
