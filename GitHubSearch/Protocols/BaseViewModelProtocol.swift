//
//  BaseViewModelProtocol.swift
//  GitHubSearch
//
//  Created by Yevhen Mekhedov on 31.01.2020.
//  Copyright © 2020 Yevhen Mekhedov. All rights reserved.
//

import Foundation
import CoreData
import GHNetwork
///Protocol for describing a common behaviour for all ViewModels
protocol BaseViewModelProtocol {
    ///This is a generic parameter which defines some entity
    associatedtype Entity: NSManagedObject
    ///This is an  instance of [NSFetchedResultsController](https://developer.apple.com/documentation/coredata/nsfetchedresultscontroller) of given entity
    var fetchedResultsController: NSFetchedResultsController<Entity> { get }
//    var sortDescriptorsDefault: [NSSortDescriptor] { get }
//    var sectionNameKeyPath: String? { get }
//    var cacheName: String? { get }
//    var predicate: NSPredicate? { get }
}
