//
//  SearchRepoSort.swift
//  GitHubSearch
//
//  Created by Yevhen Mekhedov on 22.01.2020.
//  Copyright © 2020 Yevhen Mekhedov. All rights reserved.
//

import Foundation

public enum SearchRepoSort: String {
    case stars
    case forks
    case helpWantedIssue = "help-wanted-issue"
    case updated
}
