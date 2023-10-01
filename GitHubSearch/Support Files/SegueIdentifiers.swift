//
//  SegueIdentifiers.swift
//  GitHubSearch
//
//  Created by Yevhen Mekhedov on 05.02.2020.
//  Copyright © 2020 Yevhen Mekhedov. All rights reserved.
//

import Foundation
///This is base enum for all segues in the app
enum SegueIdentifiers {
    ///Describing all segues comes from SearchViewController
    enum SearchViewController: String {
        case userRepositories = "SearchViewControllerSegueIdentifier"
    }
}
