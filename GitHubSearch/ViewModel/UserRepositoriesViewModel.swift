//
//  UserRepositoriesViewModel.swift
//  GitHubSearch
//
//  Created by Yevhen Mekhedov on 05.02.2020.
//  Copyright © 2020 Yevhen Mekhedov. All rights reserved.
//

import Foundation
import MagicalRecord
import GHNetwork
///View model for [UserRepositoriesViewController](x-source-tag://UserRepositoriesViewController)
class UserRepositoriesViewModel: RepositoriesViewModel<UserRepositories> {
    ///This is a selected repository which must have an ownerName
    var mainRepo: Repositories!

    init(repository: Repositories) {
        self.mainRepo = repository
        UserRepositories.sectionNameKeyPath = nil
        super.init()
        do {
            fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(UserRepositories.ownerName), mainRepo.ownerName!)
            try fetchedResultsController.performFetch()
        } catch _ {
            print("ERROR!")
        }
    }

    override func search(isNewRequest: Bool = true) {
        self.isLoading = true
        self.delegate?.willStartFetchingItems()
        self.page = isNewRequest ? 0 : self.page
        let group = DispatchGroup()
        MagicalRecord.save({ (localContext) in
            if isNewRequest {
                UserRepositories.mr_deleteAll(matching: self.fetchedResultsController.fetchRequest.predicate!, in: localContext)
            }
        }, completion: { (success, _) in
            var shouldCancel = isNewRequest
            for _ in 0...1 {
                group.enter()
                self.page += 1
                //swiftlint:disable:next line_length
                self.networkService?.repositories.getUserRepositories(userName: self.mainRepo.ownerName!, page: self.page, itemsInPage: 15, cancelPrevious: shouldCancel, completion: { [weak self] (result) in
                    switch result {
                    case .success(let items):
                        self?.importToEntity(items: items) { (err) in
                            if err != nil {
                                self?.delegate?.errorOccurred(message: err!.localizedDescription)
                            }
                            let set = NSSet(array: UserRepositories.mr_findAll(with: self?.fetchedResultsController.fetchRequest.predicate!)!)
                            self?.mainRepo.ownerRepositories = set
                            group.leave()
                        }
                    case .failure(let message):
                        self?.delegate?.errorOccurred(message: message)
                        group.leave()
                    }
                })
                shouldCancel = false
            }
            group.notify(queue: .main) {
                self.isLoading = false
                self.delegate?.didFinishFetchingItems()
            }
        })
    }
}
