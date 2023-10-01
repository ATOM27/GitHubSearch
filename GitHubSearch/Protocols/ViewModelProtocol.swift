//
//  ViewModelProtocol.swift
//  GitHubSearch
//
//  Created by Yevhen Mekhedov on 04.02.2020.
//  Copyright © 2020 Yevhen Mekhedov. All rights reserved.
//

import Foundation
import CoreData
import GHNetwork
///This protocol for decribing a common behaviour for all viewModels connected with repositories
///- Tag: ViewModelProtocol
protocol ViewModelProtocol: BaseViewModelProtocol, NSFetchedResultsControllerDelegate {
    ///This property represents pages from GitHub API search request
    ///- Tag: page
    var page: Int { get }

    ///Determines if we are searching
    var isLoading: Bool { get }

    ///Service for requests to the server
    var networkService: GHNetwork? { get set }

    ///Delegate which notifies that the request for fetching has begun, and how to manage tableView for Entity updates
    var delegate: (ViewModelDelegate & FetchedResultsViewModelDelegate)? { get set }

    ///get object from fetchedResultsController by indexPath and truncates the name to 30 characters
    ///- parameter indexPath: indexPath of the object
    ///- returns: the string truncated to 30 characters
    func getRepositoryName(_ indexPath: IndexPath) -> String

    ///gets number of stars from fetchedResultsController by indexPath
    ///- parameter indexPath: indexPath of the object
    ///- returns: Number of stars in String type
    func getRepoStars(_ indexPath: IndexPath) -> String

    ///Function for launching searching and sending request to the server
    ///- parameter isNewRequest: is a Bool value which defines should reset the [page](x-source-tag://page) property or continue using the current one
    func search(isNewRequest: Bool)
}
