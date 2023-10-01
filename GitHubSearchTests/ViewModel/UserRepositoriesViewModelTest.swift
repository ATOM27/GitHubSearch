//
//  UserRepositoriesViewModel.swift
//  GitHubSearchTests
//
//  Created by Yevhen Mekhedov on 10.02.2020.
//  Copyright © 2020 Yevhen Mekhedov. All rights reserved.
//

import XCTest
import Nimble
import MagicalRecord
import GHNetwork

@testable import GitHubSearch
class UserRepositoriesViewModelTest: XCTestCase {

    var userRepositoriesViewModel: UserRepositoriesViewModel?
    var userRepositoriesViewModelMockDelegate: SearchViewModelTest.SearchViewModelMockDelegate?
    var networkMock: GHNetwork?

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        MagicalRecord.setDefaultModelFrom(self.classForCoder)
        MagicalRecord.cleanUp()
        MagicalRecord.setupCoreDataStackWithInMemoryStore()

        let repoWithLongName = Repositories.mr_createEntity()
        repoWithLongName?.name = "the-swift-programming-language-guide"
        repoWithLongName?.fullName = "asdasd"
        repoWithLongName?.stars = 32
        repoWithLongName?.id = 1
        repoWithLongName?.ownerName = "atom27"
        NSManagedObjectContext.mr_default().mr_saveOnlySelfAndWait()

        userRepositoriesViewModel = UserRepositoriesViewModel(repository: repoWithLongName!)
        userRepositoriesViewModelMockDelegate = SearchViewModelTest.SearchViewModelMockDelegate()
        userRepositoriesViewModel?.delegate = userRepositoriesViewModelMockDelegate
        self.networkMock = SearchViewModelTest.NetworkMock()
        userRepositoriesViewModel?.networkService = self.networkMock

    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        MagicalRecord.cleanUp()
        userRepositoriesViewModel = nil
        userRepositoriesViewModelMockDelegate = nil
        networkMock = nil
    }

    func test_search_shouldCallWillStartFetchingItems() {
        userRepositoriesViewModel?.networkService = nil
        userRepositoriesViewModel?.search()
        expect(self.userRepositoriesViewModelMockDelegate?.willStartFetchingItemsIsCalled).toEventually(beTrue(), timeout: 10, description: "willStartFetchingItems was not called")
    }

    func test_search_shouldCallDidFinishFetchingItems() {
        let repo = Repositories.mr_findFirst()!
        let fakeViewModel = FakeUserRepoViewModel(repository: repo)
        fakeViewModel.delegate = userRepositoriesViewModelMockDelegate
        fakeViewModel.networkService = SearchViewModelTest.NetworkMock()
        fakeViewModel.search()
    expect(self.userRepositoriesViewModelMockDelegate?.didFinishFetchingItemsIsCalled).toEventually(beTrue(), timeout: 10, description: "didFinishFetchingItems was not called")
    }

    func test_search_shouldCallErrorOcured() {
        (networkMock?.repositories as? SearchViewModelTest.RepositoriesServiceTest)?.shouldReturnError = true
        userRepositoriesViewModel?.search()
        expect(self.userRepositoriesViewModelMockDelegate?.errorOccurredIsCalled).toEventually(beTrue(), timeout: 5, description: "errorOcured was not called")
    }

    func test_search_pageShouldBeTwo() {
        userRepositoriesViewModel?.search(isNewRequest: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.userRepositoriesViewModel?.search(isNewRequest: false)
        }
        expect((self.networkMock?.repositories as? SearchViewModelTest.RepositoriesServiceTest)?.page).toEventually(equal(2), timeout: 10)
    }

    func test_search_importToEntityReturnsNil_shouldCallErrorOcured() {
        let repo = Repositories.mr_findFirst()!
        let fakeViewModel = FakeUserRepoViewModel(repository: repo)
        fakeViewModel.delegate = userRepositoriesViewModelMockDelegate
        fakeViewModel.networkService = SearchViewModelTest.NetworkMock()
        fakeViewModel.search()
        expect(self.userRepositoriesViewModelMockDelegate?.errorOccurredIsCalled).toEventually(beTrue(), timeout: 10)
    }
}

extension UserRepositoriesViewModelTest {
    class FakeUserRepoViewModel: UserRepositoriesViewModel {
        override func importToEntity(items: [NSObjectProtocol], completion: @escaping ((Error?) -> Void)) {
            completion(GHError.defaultError)
        }
    }
}
