//
//  SearchViewModelTest.swift
//  GitHubSearchTests
//
//  Created by Yevhen Mekhedov on 30.01.2020.
//  Copyright © 2020 Yevhen Mekhedov. All rights reserved.
//

import XCTest
import Nimble
import CoreData
import MagicalRecord
import GHNetwork

@testable import GitHubSearch
class SearchViewModelTest: XCTestCase {

    var searchViewModel: SearchViewModel?
    var searchViewModelMockDelegate: SearchViewModelMockDelegate?
    var networkMock: GHNetwork?

    override class func setUp() {
        super.setUp()
        //MagicalRecord.setDefaultModelFrom(self.classForCoder())
        //MagicalRecord.cleanUp()
        //MagicalRecord.setupCoreDataStackWithInMemoryStore()
    }

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        //MagicalRecord.setupCoreDataStackWithInMemoryStore()
        MagicalRecord.setDefaultModelFrom(self.classForCoder)
        MagicalRecord.cleanUp()
        MagicalRecord.setupCoreDataStackWithInMemoryStore()

        //Repositories.mr_truncateAll()
        //UserRepositories.mr_truncateAll()
        //NSManagedObjectContext.mr_default().mr_saveOnlySelfAndWait()
        searchViewModel = SearchViewModel()
        searchViewModelMockDelegate = SearchViewModelMockDelegate()
        searchViewModel?.delegate = searchViewModelMockDelegate
        self.networkMock = NetworkMock()
        searchViewModel?.networkService = self.networkMock
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.

        //NSManagedObjectContext.mr_default().mr_saveOnlySelfAndWait()
        MagicalRecord.cleanUp()
        searchViewModel = nil
        searchViewModelMockDelegate = nil
    }

    override class func tearDown() {
        super.tearDown()
       // MagicalRecord.cleanUp()
    }

    func test_search_shouldCallWillStartFetchingItems() {
        searchViewModel?.networkService = nil
        searchViewModel?.searchText = "swift"
        searchViewModel?.search()
        expect(self.searchViewModelMockDelegate?.willStartFetchingItemsIsCalled).toEventually(beTrue(), timeout: 10, description: "willStartFetchingItems was not called")
    }

    func test_search_shouldCallDidFinishFetchingItems() {
        searchViewModel?.searchText = "swift"
        searchViewModel?.search()
        expect(self.searchViewModelMockDelegate?.didFinishFetchingItemsIsCalled).toEventually(beTrue(), timeout: 10, description: "didFinishFetchingItems was not called")
    }

    func test_search_shouldCallErrorOcured() {
        (networkMock?.search as? SearchServiceTest)?.shouldReturnError = true
        searchViewModel?.searchText = "sw"
        searchViewModel?.search()
        expect(self.searchViewModelMockDelegate?.errorOccurredIsCalled).toEventually(beTrue(), timeout: 5, description: "errorOcured was not called")
    }

    func test_search_WithEmptyStringAndNewRequest_shouldReturnFalse() {
        searchViewModel?.networkService = nil
        searchViewModel?.searchText = ""
        searchViewModel?.search(isNewRequest: true)
        expect(self.searchViewModelMockDelegate?.willStartFetchingItemsIsCalled).toEventually(beFalse(), timeout: 5, description: "If searchName = \"\" willStartFetching should not be called")
    }

    func test_search_withEmptyStringAndOldRequest_shouldReturnfalse() {
        searchViewModel?.networkService = nil
        searchViewModel?.searchText = ""
        searchViewModel?.search(isNewRequest: false)
        expect(self.searchViewModelMockDelegate?.willStartFetchingItemsIsCalled).toEventually(beFalse(), timeout: 5, description: "If searchName = \"\" willStartFetching should not be called")
    }

    func test_search_withOldRequest_pageShouldBeTwo() {
        searchViewModel?.searchText = "s"
        searchViewModel?.search(isNewRequest: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.searchViewModel?.searchText = "sw"
            self.searchViewModel?.search(isNewRequest: false)
        }
        expect((self.networkMock?.search as? SearchServiceTest)?.page).toEventually(equal(2), timeout: 10)
    }

    func test_search_withOldRequest_pageShouldBeFour() {
        (networkMock?.search as? SearchServiceTest)?.shouldReturnError = true
        searchViewModel?.searchText = "s"
        searchViewModel?.search(isNewRequest: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.searchViewModel?.search(isNewRequest: false)
        }
        expect((self.networkMock?.search as? SearchServiceTest)?.page).toEventually(equal(4), timeout: 10)
    }

    func test_search_importToEntityReturnsNil_shouldCallErrorOcured() {
        let fakeViewModel = FakeViewModel()
        fakeViewModel.delegate = searchViewModelMockDelegate
        fakeViewModel.networkService = networkMock
        fakeViewModel.searchText = "asd"
        fakeViewModel.search()
        expect(self.searchViewModelMockDelegate?.errorOccurredIsCalled).toEventually(beTrue(), timeout: 10)
    }

    func test_searchResultsUpdating_shouldEqualStrings() {
        let searchController = UISearchController(searchResultsController: nil)
        //controller.searchController = searchController
        let fakeViewModel = FakeViewModel()
        fakeViewModel.shouldCallSuper = false
        searchController.searchResultsUpdater = fakeViewModel
        searchController.searchBar.delegate = fakeViewModel

        searchController.searchBar.text = "testString"
        expect(fakeViewModel.searchName).to(match("testString"))
    }

    func test_searchBarSearchButtonClick_shouldEqualStrings() {
        let searchController = UISearchController(searchResultsController: nil)
        //controller.searchController = searchController
        let fakeViewModel = FakeViewModel()
        fakeViewModel.shouldCallSuper = false
        searchController.searchResultsUpdater = fakeViewModel
        searchController.searchBar.delegate = fakeViewModel

        searchController.searchBar.text = "testString"
        fakeViewModel.searchName = ""
        fakeViewModel.searchBarSearchButtonClicked(searchController.searchBar)
        expect(fakeViewModel.searchName).to(match("testString"))
    }
}

extension SearchViewModelTest {
    class SearchViewModelMockDelegate: ViewModelDelegate, FetchedResultsViewModelDelegate {
        var isControllerWillChangeConttentCalled = false
        var isControllerDidChangeObjectCalled = false
        var isControllerDidChangeContentCalled = false

        func controllerWillChangeContent() {
            isControllerWillChangeConttentCalled = true
        }

        func controllerDidChangeObject(at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
            isControllerDidChangeObjectCalled = true
        }

        func controllerDidChangeContent() {
            isControllerDidChangeContentCalled = true
        }

        var errorOccurredIsCalled = false
        var willStartFetchingItemsIsCalled = false
        var didFinishFetchingItemsIsCalled = false

        func errorOccurred(message: String) {
            errorOccurredIsCalled = true
        }

        func willStartFetchingItems() {
            willStartFetchingItemsIsCalled = true
        }

        func didFinishFetchingItems() {
            didFinishFetchingItemsIsCalled = true
        }
    }

    class FetchedResultsControllerMockDelegate: NSObject, NSFetchedResultsControllerDelegate {
        func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                        didChange anObject: Any,
                        at indexPath: IndexPath?,
                        for type: NSFetchedResultsChangeType,
                        newIndexPath: IndexPath?) {
            print(indexPath as Any)
        }
    }
}

extension SearchViewModelTest {
    class FakeItem: NSObject, GHItem {
        var ownerName: String
    //swiftlint:disable:next identifier_name
            var id: Int
            var fullName: String
            var stars: Int
            var name: String

            init(name: String,
                 fullName: String,
                 //swiftlint:disable:next identifier_name
                 id: Int,
                 stars: Int,
                 ownerName: String) {
                self.name = name
                self.fullName = fullName
                self.id = id
                self.stars = stars
                self.ownerName = ownerName
            }
        }

    class NetworkMock: GHNetwork {
        var search: GHSearchService
        var repositories: GHRepositoriesService
        init() {
            search = SearchServiceTest()
            repositories = RepositoriesServiceTest()
        }
    }

    class SearchServiceTest: GHSearchService {
        var shouldReturnError = false
        var page = 0
        //swiftlint:disable:next function_parameter_count
        func find(name: String, sort: SearchRepoSort, page: Int, itemsInPage: Int, cancelPrevious: Bool, completion: @escaping Completion<[GHItem]>) {
            self.page = page
            if shouldReturnError {
                let res: GHResult<[GHItem]> = GHResult(value: nil, error: GHError.defaultError.localizedDescription)
                completion(res)
                return
            }
            let fakeItem = FakeItem(name: "name", fullName: "fakeName", id: 1, stars: 0, ownerName: "ownerName")
            let res: GHResult<[GHItem]> = GHResult(value: [fakeItem], error: nil)
            completion(res)
        }
    }
    class RepositoriesServiceTest: GHRepositoriesService {
        var shouldReturnError = false
        var page = 0
        func getUserRepositories(userName: String, page: Int, itemsInPage: Int, cancelPrevious: Bool, completion: @escaping Completion<[GHItem]>) {
            self.page = page
            if shouldReturnError {
                let res: GHResult<[GHItem]> = GHResult(value: nil, error: GHError.defaultError.localizedDescription)
                completion(res)
                return
            }
            let fakeItem = FakeItem(name: "name", fullName: "fakeName", id: Int.random(in: 2...2000), stars: 0, ownerName: "atom27")
            let res: GHResult<[GHItem]> = GHResult(value: [fakeItem], error: nil)
            completion(res)
        }
    }

    class FakeViewModel: SearchViewModel {
        override func importToEntity(items: [NSObjectProtocol], completion: @escaping ((Error?) -> Void)) {
            completion(GHError.defaultError)
        }
        var searchName = ""
        var shouldCallSuper = true
        override func search(isNewRequest: Bool = true) {
            self.searchName = searchText
            if shouldCallSuper {
                super.search(isNewRequest: isNewRequest)
            }
        }
    }
}
