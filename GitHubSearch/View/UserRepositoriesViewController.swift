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
///This is a view controller for displaying selected user's repo repositories
///- Tag: UserRepositoriesViewController
class UserRepositoriesViewController: BaseViewController<UserRepositoriesViewModel> {

    @IBOutlet weak var tableView: UITableView!

    //var userRepositoriesViewModel: UserRepositoriesViewModel?

    ///Refresh controll that can initiate the refreshing of a scroll view’s contents.
    let refreshControll = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel?.delegate = self
        //userRepositoriesViewModel?.fetchedResultsController.delegate = userRepositoriesViewModel
        refreshControll.addTarget(self, action: #selector(refreshControllAction), for: .valueChanged)
        tableView.addSubview(refreshControll)
        viewModel?.search()
    }

    // MARK: - Help methods
    ///Function for configurating [UISearchController](https://developer.apple.com/documentation/uikit/uisearchcontroller)
    @objc func refreshControllAction() {
        viewModel?.search()
    }
}

extension UserRepositoriesViewController: ViewModelDelegate {
    // MARK: - SearchViewModelDelegate
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
//
extension UserRepositoriesViewController: FetchedResultsViewModelDelegate {
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
