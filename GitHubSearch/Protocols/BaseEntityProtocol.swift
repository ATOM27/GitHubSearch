//
//  BaseEntityProtocol.swift
//  GitHubSearch
//
//  Created by Yevhen Mekhedov on 11.02.2020.
//  Copyright © 2020 Yevhen Mekhedov. All rights reserved.
//

import Foundation
import CoreData
/// This protocol describing which properties must implement EACH entity to be used in BaseViewModel
@objc protocol BaseEntityProtocol where Self: NSManagedObject {
    ///The sort descriptors specify how the objects returned when the NSFetchRequest is issued should be ordered. Used for creation of NSFetchedResultsController.
   // static var sortDescriptors: [NSSortDescriptor] { get set }
    ///Computed property which must contain keys which will be used by fetch for describing sort
    @objc static var sortingKeys: [String] { get }
    ///The name of the cache file the receiver should use. Pass nil to prevent caching. Used for creation of NSFetchedResultsController.
    @objc static var sectionNameKeyPath: String? { get set }

    ///The name of the cache file the receiver should use. Pass nil to prevent caching. Used for creation of NSFetchedResultsController.
    @objc static var cacheName: String? { get }

    ///The predicate of the fetch request.
    //static var predicate: NSPredicate? { get set }
}
