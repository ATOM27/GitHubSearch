//
//  SearchViewModel.swift
//  GitHubSearch
//
//  Created by Yevhen Mekhedov on 23.01.2020.
//  Copyright © 2020 Yevhen Mekhedov. All rights reserved.
//

import Foundation
import GHNetwork
import CoreData
import MagicalRecord

///This is a struct with static parameters which represents keys. Use this struct to get values from UserInfo dictionary
private struct UserInfoKeys {
    static var searchName = "searchName"
    static var isNewRequest = "isNewRequest"
}

///View model for [SearchViewController](x-source-tag://SearchViewController)
class SearchViewModel: RepositoriesViewModel<Repositories> {

    // MARK: - Private properties
    /**
     Property for interval before sending request
     
     timer needed for making interval before sending request to the server in period of typing. In timeInterval: you can set the time which should be without typing to start sending requests
        
     Code example:
     
         timer = Timer.scheduledTimer(timeInterval: 0.5, //Every 0.5 will be executing selector
         target: self,
         selector: #selector(YOUR_SELECTOR),
         userInfo: YOUR_USER_INFO,
         repeats: false)

     
     */
    private var timer: Timer?
    ///A property which updates every time the user taps keyboard
    var searchText = ""
    ///A property which defines the last text the user has searched
    private var previousSearchText = ""
    // MARK: - Initialization

    override init() {
        Repositories.sectionNameKeyPath = nil
        super.init()
        do {
            try fetchedResultsController.performFetch()
        } catch _ {
            print("ERROR!")
        }
    }
    // MARK: - Help methods
    ///Private function for making request
    ///
    ///This function is executing from [search(searchName:isNewRequest:)](x-source-tag://search) and making request to the server and in completion block import results to Repositories CoreData entity
    ///- parameter timer: needed for passing info from selector in UserInfo
    ///- Tag: makeRequest
    @objc private func makeRequest(timer: Timer) {
        self.isLoading = true
        guard let userInfo = timer.userInfo as? [String: Any],
            let searchName = userInfo[UserInfoKeys.searchName] as? String, // get info from timer userDefaults
            let isNewRequest = userInfo[UserInfoKeys.isNewRequest] as? Bool else {
            self.delegate?.errorOccurred(message: "Can't pass search text to request")
            return
        }
        self.page = isNewRequest ? 0 : self.page // if in searchBar was typed new text than page property resets to 0
        let group = DispatchGroup()
        MagicalRecord.save({ (localContext) in
            if isNewRequest {
                Repositories.mr_truncateAll(in: localContext) // if in searchBar was typed new text than clear data from repositories
            }
        }, completion: { (success, _) in
            var shouldCancel = isNewRequest /* we have 2 async requests and if isNewRequest is
            `true` than GHNetwork cancels all previous requests. This helps not to cancel the
            second asunc request, but only new ones */
            for _ in 0...1 {
                group.enter()
                self.page += 1
                self.networkService?.search.find(name: searchName, sort: .stars, page: self.page, itemsInPage: 15, cancelPrevious: shouldCancel) { [weak self] (result) in
                    switch result {
                    case .success(let items):
                        self?.importToEntity(items: items) { (err) in
                            if err != nil {
                                self?.delegate?.errorOccurred(message: err!.localizedDescription)
                            }
                            group.leave()
                        }
                    case .failure(let message):
                        self?.delegate?.errorOccurred(message: message)
                        group.leave()
                    }
                }
                shouldCancel = false // after first execution of the request set to false. This helps not to cancel the next request
            }
            group.notify(queue: .main) {
                self.isLoading = false
                self.delegate?.didFinishFetchingItems()
            }
        })
    }

    ///Public method to execute [makeRequest(timer:)](x-source-tag://makeRequest)
    ///- parameter searchName: pass here what you want to search
    ///- parameter isNewRequest: Bool value to determine if start searching from the top of the list
    ///- Tag: search
    override func search(isNewRequest: Bool = true) {
        if isNewRequest {
            guard searchText != "" else { return }
        }
        guard searchText != "" else { return }
        previousSearchText = searchText
        delegate?.willStartFetchingItems()
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.5,
                                     target: self,
                                     selector: #selector(makeRequest),
                                     userInfo: [UserInfoKeys.searchName: searchText,
                                                UserInfoKeys.isNewRequest: isNewRequest],
                                     repeats: false)
    }
}

extension SearchViewModel: UISearchResultsUpdating, UISearchBarDelegate {
    // MARK: - UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        searchText = searchController.searchBar.text!
        search()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchText = searchBar.text!
        search()
    }
}
