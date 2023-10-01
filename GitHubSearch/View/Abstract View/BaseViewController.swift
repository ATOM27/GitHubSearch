//
//  BaseViewController.swift
//  GitHubSearch
//
//  Created by Yevhen Mekhedov on 06.02.2020.
//  Copyright © 2020 Yevhen Mekhedov. All rights reserved.
//

import UIKit
///This is a generic view controller for describing a common behaviour for controllers which have viewModel conformed by ViewModelProtocol and having the same behaviour of tabelView
class BaseViewController<ViewModel: ViewModelProtocol>: UIViewController, UITableViewDelegate, UITableViewDataSource {
///ViewModel of the current controller which conforms to [ViewModelProtocol](x-source-tag://ViewModelProtocol)
    var viewModel: ViewModel?

    // MARK: - DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = viewModel?.getRepositoryName(indexPath)
        cell.detailTextLabel?.text = viewModel?.getRepoStars(indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    // MARK: - Delegate

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let searchViewModel = viewModel,
        let fetchedObjects = searchViewModel.fetchedResultsController.fetchedObjects else {
            return
        }
        let isItemsEmpty = fetchedObjects.isEmpty
        if !isItemsEmpty {
            let allItemsCount = fetchedObjects.count
            let lastItemRow = allItemsCount - 1
            if lastItemRow == indexPath.row && !searchViewModel.isLoading {
                searchViewModel.search(isNewRequest: false)
            }
        }
    }
}
