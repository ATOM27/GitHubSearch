//
//  ViewModelDelegate.swift
//  GitHubSearch
//
//  Created by Yevhen Mekhedov on 24.01.2020.
//  Copyright © 2020 Yevhen Mekhedov. All rights reserved.
//

import Foundation
import GHNetwork

///This is a protocol which describes methods which will be triggered by ViewModel for some actions
protocol ViewModelDelegate: AnyObject {
    ///called before execution from CoreData and Server
    func willStartFetchingItems()

    ///called after execution from CoreData and Server
    func didFinishFetchingItems()

    /** Called when some error ocured while executing from CoreData or server
    - parameters:
        - message: String representation of error
    */
    func errorOccurred(message: String)
}
