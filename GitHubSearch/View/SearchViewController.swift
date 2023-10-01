//
//  SearchViewController.swift
//  GitHubSearch
//
//  Created by Yevhen Mekhedov on 23.01.2020.
//  Copyright © 2020 Yevhen Mekhedov. All rights reserved.
//

import UIKit
import GHNetwork
import CoreData
///This is a view controller for searching repositories by their names
///- Tag: SearchViewModel
class SearchViewController: BaseViewController<SearchViewModel> {

    @IBOutlet weak var tableView: UITableView!

    //var searchViewModel: SearchViewModel?
    ///A view controller that manages the display of search results based on interactions with a search bar.
    var searchController: UISearchController?

    ///Refresh controll that can initiate the refreshing of a scroll view’s contents.
    let refreshControll = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupSearchBar()
        viewModel?.delegate = self
        //searchViewModel?.delegate = self
        //searchViewModel?.fetchedResultsController.delegate = searchViewModel
        refreshControll.addTarget(self, action: #selector(refreshControllAction), for: .valueChanged)
        tableView.addSubview(refreshControll)
    }

    // MARK: - Help methods
    ///Function for configurating [UISearchController](https://developer.apple.com/documentation/uikit/uisearchcontroller)
    func setupSearchBar() {
        searchController?.searchResultsUpdater = viewModel
        searchController?.obscuresBackgroundDuringPresentation = false
        searchController?.searchBar.placeholder = "Search here for repositories"
        searchController?.searchBar.delegate = viewModel
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    @objc func refreshControllAction() {
        viewModel?.search(isNewRequest: true)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        let selectedRepo = viewModel?.fetchedResultsController.object(at: indexPath)
        self.performSegue(withIdentifier: SegueIdentifiers.SearchViewController.userRepositories.rawValue, sender: selectedRepo)
    }
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifiers.SearchViewController.userRepositories.rawValue {
            let destinationVC = segue.destination as? UserRepositoriesViewController
            guard let repo = sender as? Repositories,
                repo.ownerName != nil else {
                self.addAlert(title: "Error", message: "Repository is not given or ownerName does not exist", completion: nil)
                return
            }
            destinationVC?.viewModel = UserRepositoriesViewModel(repository: repo)
            destinationVC?.viewModel?.networkService = GHNetworkImpl()
        }
    }
}

extension SearchViewController: ViewModelDelegate {
    // MARK: - ViewModelDelegate
    @objc func errorOccurred(message: String) {
        refreshControll.endRefreshing()
        self.addAlert(title: "Error!", message: message, completion: nil)
    }

    @objc func willStartFetchingItems() {
        refreshControll.beginRefreshing()
    }

    @objc func didFinishFetchingItems() {
        refreshControll.endRefreshing()
    }
}

extension SearchViewController: FetchedResultsViewModelDelegate {
    // MARK: - NSFetchedResultsControllerDelegate
    func controllerWillChangeContent() {
      tableView.beginUpdates()
    }

    func controllerDidChangeObject(at indexPath: IndexPath?,
                                   for type: NSFetchedResultsChangeType,
                                   newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .automatic)
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        @unknown default:
            print("DEFAULT BEHAVIOUR!")
        }
    }

    func controllerDidChangeContent() {
      tableView.endUpdates()
    }
}
