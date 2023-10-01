//
//  UserRepositoriesViewControllerTest.swift
//  GitHubSearchTests
//
//  Created by Yevhen Mekhedov on 07.02.2020.
//  Copyright © 2020 Yevhen Mekhedov. All rights reserved.
//

import XCTest
import MagicalRecord
import Nimble

@testable import GitHubSearch
class UserRepositoriesViewControllerTest: XCTestCase {

        override class func setUp() {
        super.setUp()
        MagicalRecord.setDefaultModelFrom(self.classForCoder())
        MagicalRecord.cleanUp()
        MagicalRecord.setupCoreDataStackWithInMemoryStore()
    }

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        //Repositories.mr_truncateAll()
        //NSManagedObjectContext.mr_default().mr_saveOnlySelfAndWait()
        //MagicalRecord.cleanUp()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        Repositories.mr_truncateAll()
        UserRepositories.mr_truncateAll()
        //NSManagedObjectContext.mr_default().mr_saveOnlySelfAndWait()
        //MagicalRecord.cleanUp()
    }

    override class func tearDown() {
        super.tearDown()
        MagicalRecord.cleanUp()
    }

    var tableView: UITableView!
    var viewModel: UserRepositoriesViewModelMock!

    func initialSetup() -> UserRepositoriesViewControllerMock {
        let userRepositoriesViewController = UserRepositoriesViewControllerMock()
        tableView = UITableView()
        userRepositoriesViewController.tableView = tableView

        let repoWithLongName = UserRepositories.mr_createEntity()
        repoWithLongName?.name = "the-swift-programming-language-guide"
        repoWithLongName?.fullName = "asdasd"
        repoWithLongName?.stars = 32
        repoWithLongName?.id = 1
        repoWithLongName?.ownerName = "TestName"
        NSManagedObjectContext.mr_default().mr_saveOnlySelfAndWait()

        viewModel = UserRepositoriesViewModelMock(repository: repoWithLongName!)
        userRepositoriesViewController.viewModel = viewModel
        viewModel.delegate = userRepositoriesViewController

        return userRepositoriesViewController
    }

    func test_refreshControllAction_ShouldCallSearchWithIsNewRequestToTrue() {
        let userRepositoriesViewController = initialSetup()
        tableView.addSubview(userRepositoriesViewController.refreshControll)
        userRepositoriesViewController.refreshControllAction()
        expect(self.viewModel.isSearchCalledWithIsNewRequest).to(beTrue())
    }

    func test_errorMessage_ShouldPassErrorMessage() {
        let userRepositoriesViewController = initialSetup()
        let testMessage = "Some test message"
        userRepositoriesViewController.errorOccurred(message: testMessage)
        expect(userRepositoriesViewController.message).to(match(testMessage))
    }

    func test_willStartFetchingItemsDidFinishFetchingItems_ShouldStartRefreshingAndEndRefreshing() {
        let userRepositoriesViewController = initialSetup()
        userRepositoriesViewController.willStartFetchingItems()
        expect(userRepositoriesViewController.refreshControll.isRefreshing).to(beTrue())
        userRepositoriesViewController.didFinishFetchingItems()
        expect(userRepositoriesViewController.refreshControll.isRefreshing).to(beFalse())
    }

    func test_addRepository_shoudUpdateNumberOfRowsInSection() {
        let userRepositoriesViewController = initialSetup()

        let anotherRepo = UserRepositories.mr_createEntity()
        anotherRepo?.name = "another repo"
        anotherRepo?.fullName = "asdasd"
        anotherRepo?.stars = 32
        anotherRepo?.id = 2
        anotherRepo?.ownerName = "TestName"
        NSManagedObjectContext.mr_default().mr_saveOnlySelfAndWait()

        let tableViewRows = userRepositoriesViewController.tableView(userRepositoriesViewController.tableView, numberOfRowsInSection: 0)
        expect(tableViewRows).to(equal(2))
    }
}

extension UserRepositoriesViewControllerTest {
    class UserRepositoriesViewControllerMock: UserRepositoriesViewController {
        var message: String!
        override func errorOccurred(message: String) {
            self.message = message
            super.errorOccurred(message: message)
        }
    }

    class UserRepositoriesViewModelMock: UserRepositoriesViewModel {
        var isSearchCalled = false
        var isSearchCalledWithIsNewRequest = false
        override func search(isNewRequest: Bool = true) {
            isSearchCalled = true
            isSearchCalledWithIsNewRequest = isNewRequest
        }

    }
}
