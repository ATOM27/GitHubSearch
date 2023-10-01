//
//  FetchedResultsViewModel.swift
//  GitHubSearch
//
//  Created by Yevhen Mekhedov on 31.01.2020.
//  Copyright © 2020 Yevhen Mekhedov. All rights reserved.
//

import Foundation
import CoreData
///This is a protocol which gives ability to your view to know when the tableView should be updated
protocol FetchedResultsViewModelDelegate: AnyObject {
    ///Notifies the delegate that section and object changes are about to be processed and notifications will be sent
    func controllerWillChangeContent()

    ///Notifies the delegate that a fetched object has been changed due to an add, remove, move, or update
    ///- parameter indexPath: The index path of the changed object (this value is nil for insertions).
    ///- parameter type: The type of change. For valid values see [NSFetchedResultsChangeType](https://developer.apple.com/documentation/coredata/nsfetchedresultschangetype).
    ///- parameter newIndexPath: The destination path for the object for insertions or moves (this value is nil for a deletion).
    func controllerDidChangeObject(at indexPath: IndexPath?,
                                   for type: NSFetchedResultsChangeType,
                                   newIndexPath: IndexPath?)

    ///Notifies the delegate that all section and object changes have been sent
    func controllerDidChangeContent()
}
