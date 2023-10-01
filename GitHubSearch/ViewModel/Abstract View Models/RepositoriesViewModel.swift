//
//  RepositoriesViewModel.swift
//  GitHubSearch
//
//  Created by Yevhen Mekhedov on 06.02.2020.
//  Copyright © 2020 Yevhen Mekhedov. All rights reserved.
//

import Foundation
import CoreData
import GHNetwork
///This is viewModel for describing common behaviour for all ViewModels connected with repositories
class RepositoriesViewModel<Entity: RepositoriesProtocol>: BaseViewModel<Entity>, ViewModelProtocol {

    var networkService: GHNetwork?
    ///Delegete for notify when actions trigger
    weak var delegate: (FetchedResultsViewModelDelegate & ViewModelDelegate)?

    ///This property represents pages from GitHub API search request
    var page: Int = 0
    ///Determines if we are searching
    var isLoading: Bool = false

    override init() {
        super.init()
        fetchedResultsController.delegate = self
    }

    func search(isNewRequest: Bool) {
        fatalError("search(isNewRequest:) should be overridden in subclass")
    }

    /**
    Gets object from fetchedResultsController by indexPath and truncates the name to 30 characters
    - parameter indexPath: indexPath of the object
    - returns: the string truncated to 30 characters
     */
    func getRepositoryName(_ indexPath: IndexPath) -> String {
        let repository = fetchedResultsController.object(at: indexPath)
        var repoNameReturn: String
        let repoNameInitial = repository.name ?? ""
        if repoNameInitial.count > 30 {
            //let startIndex = repository.name!.startIndex
            //let lastAccessibleIndex = repository.name!.index(startIndex, offsetBy: 30)
            repoNameReturn = String(repository.name!.prefix(30) + "...")
        } else {
            repoNameReturn = repoNameInitial
        }
        return repoNameReturn
    }

    /**
     Gets number of stars from fetchedResultsController by indexPath
    - parameter indexPath: indexPath of the object
    - returns: Number of stars in String type
     */
    func getRepoStars(_ indexPath: IndexPath) -> String {
        let repository = fetchedResultsController.object(at: indexPath)
        return "\(repository.stars)"
    }

    // MARK: - NSFetchedResultsControllerDelegate
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.controllerWillChangeContent()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        delegate?.controllerDidChangeObject(at: indexPath,
                                           for: type,
                                           newIndexPath: newIndexPath)
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.controllerDidChangeContent()
    }
}
