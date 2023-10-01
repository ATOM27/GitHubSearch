//
//  UIViewController+Alert.swift
//  GitHubSearch
//
//  Created by Yevhen Mekhedov on 23.01.2020.
//  Copyright © 2020 Yevhen Mekhedov. All rights reserved.
//

import UIKit

extension UIViewController {
    ///Function for adding alert controller with `OK` button
    /// - parameter title: title of the alert
    /// - parameter message: message of the alert
    /// - parameter completion: completion closure which triggers after presenting alertController
    func addAlert(title: String?, message: String?, completion: (() -> Void)?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let actionOK = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(actionOK)
        self.present(alertController, animated: true, completion: completion)
    }
}
