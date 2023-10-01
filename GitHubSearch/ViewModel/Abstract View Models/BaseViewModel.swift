//
//  BaseViewModel.swift
//  GitHubSearch
//
//  Created by Yevhen Mekhedov on 28.01.2020.
//  Copyright © 2020 Yevhen Mekhedov. All rights reserved.
//

import Foundation
import CoreData
import MagicalRecord
import GHNetwork

///Base ViewModel which only configurates [NSFetchedResultsController](https://developer.apple.com/documentation/coredata/nsfetchedresultscontroller)
class BaseViewModel<Entity: BaseEntityProtocol>: NSObject, BaseViewModelProtocol {
    ///A controller that you use to manage the results of a Core Data fetch request and to display data to the user.
    ///Delegate property in fetchedResultsController assignd to ViewModel automatically, you can change it in any time
    lazy var fetchedResultsController: NSFetchedResultsController<Entity> = {
        // swiftlint:disable:next force_cast
        let fetchRequest = Entity.mr_requestAll() as! NSFetchRequest<Entity>
        fetchRequest.includesSubentities = false
        fetchRequest.sortDescriptors = []
        Entity.sortingKeys.forEach({
            fetchRequest.sortDescriptors?.append(NSSortDescriptor(key: $0, ascending: false))
        })
        let fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                managedObjectContext: NSManagedObjectContext.mr_default(),
                                                                sectionNameKeyPath: Entity.sectionNameKeyPath,
                                                                cacheName: Entity.cacheName)
        return fetchResultsController
    }()

    ///Method used to import objects into CoreData entity via [MagicalRecord](https://github.com/magicalpanda/MagicalRecord).
    ///Import is in the background thread
    ///- parameter items: Objects are going to import into CoreData entity
    ///- parameter completion: Completion block executes after import into CoreData has been completed
    func importToEntity(items: [NSObjectProtocol], completion: @escaping ((Error?) -> Void)) {
        MagicalRecord.save({ (localContext) in
            items.forEach { (item) in
                Entity.mr_import(from: item, in: localContext)
            }
        }, completion: { (_, err) in
            completion(err)
        })
    }
}
