//
//  SearchViewControllerTest.swift
//  GitHubSearchTests
//
//  Created by Yevhen Mekhedov on 29.01.2020.
//  Copyright © 2020 Yevhen Mekhedov. All rights reserved.
//

import XCTest
import MagicalRecord
import Nimble

@testable import GitHubSearch
class SearchViewControllerTest: XCTestCase {

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
    var viewModel: TestSearchViewModel!

    func initialSetup() -> TestSearchViewController {
        let searchViewController = TestSearchViewController()
        tableView = UITableView()
        searchViewController.tableView = tableView

        viewModel = TestSearchViewModel()
        searchViewController.viewModel = viewModel
        viewModel.delegate = searchViewController

        return searchViewController
    }

    func test_errorMessage_ShouldPassErrorMessage() {
        let searchViewController = initialSetup()
        let testMessage = "Some test message"
        searchViewController.errorOccurred(message: testMessage)
        expect(searchViewController.message).to(match(testMessage))
    }

    func test_willStartFetchingItemsDidFinishFetchingItems_ShouldStartRefreshingAndEndRefreshing() {
        let searchViewControllerMock = initialSetup()
        searchViewControllerMock.willStartFetchingItems()
        expect(searchViewControllerMock.refreshControll.isRefreshing).to(beTrue())
        searchViewControllerMock.didFinishFetchingItems()
        expect(searchViewControllerMock.refreshControll.isRefreshing).to(beFalse())
    }

    func test_refreshControllAction_ShouldCallSearchWithIsNewRequestToTrue() {
        let searchViewController = initialSetup()
        tableView.addSubview(searchViewController.refreshControll)
        searchViewController.refreshControllAction()
        expect(self.viewModel.isSearchCalledWithIsNewRequest).to(beTrue())
    }

    func test_prepare_shouldPassSelectedRepoToPerformSegue() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let searchVC = storyboard.instantiateViewController(identifier: "SearchViewController") as? SearchViewController
        let userRepoVC = storyboard.instantiateViewController(identifier: "UserRepositoriesViewController") as? UserRepositoriesViewController

        let targetSegue = UIStoryboardSegue(identifier: SegueIdentifiers.SearchViewController.userRepositories.rawValue, source: searchVC!, destination: userRepoVC!)

        let repoWithLongName = Repositories.mr_createEntity()
        repoWithLongName?.name = "the-swift-programming-language-guide"
        repoWithLongName?.fullName = "asdasd"
        repoWithLongName?.stars = 32
        repoWithLongName?.id = 1
        repoWithLongName?.ownerName = "TestName"
        NSManagedObjectContext.mr_default().mr_saveOnlySelfAndWait()

        searchVC?.prepare(for: targetSegue, sender: repoWithLongName)
        expect(repoWithLongName).to(equal(userRepoVC?.viewModel?.mainRepo))
    }

    func test_didSelectRow_shouldPassSelectedRepoToPerformSegue() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        let searchVC = storyboard.instantiateViewController(identifier: "SearchViewController") as? SearchViewController
        searchVC?.viewModel = SearchViewModel()
        _ = searchVC?.view

        UIApplication.shared.keyWindow?.rootViewController = searchVC

        let repoWithLongName = Repositories.mr_createEntity()
        repoWithLongName?.name = "the-swift-programming-language-guide"
        repoWithLongName?.fullName = "asdasd"
        repoWithLongName?.stars = 32
        repoWithLongName?.id = 1
        repoWithLongName?.ownerName = "TestName"
        NSManagedObjectContext.mr_default().mr_saveOnlySelfAndWait()

        searchVC?.tableView(searchVC!.tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        expect(searchVC?.presentedViewController).toNot(beNil())
        let userRepoViewController = searchVC?.presentedViewController as? UserRepositoriesViewController
        userRepoViewController?.viewModel?.networkService = nil
        expect(userRepoViewController?.viewModel?.mainRepo).to(equal(repoWithLongName))
    }

    func test_performSegueWithEnptyNameRepo_shouldPassNilToDestination() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        let searchVC = storyboard.instantiateViewController(identifier: "SearchViewController") as? SearchViewController
        searchVC?.viewModel = SearchViewModel()
        _ = searchVC?.view

        UIApplication.shared.keyWindow?.rootViewController = searchVC

        let repoWithLongName = Repositories.mr_createEntity()
        repoWithLongName?.name = "the-swift-programming-language-guide"
        repoWithLongName?.fullName = "asdasd"
        repoWithLongName?.stars = 32
        repoWithLongName?.id = 1
        NSManagedObjectContext.mr_default().mr_saveOnlySelfAndWait()

        searchVC?.tableView(searchVC!.tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        expect(searchVC?.presentedViewController).toNot(beNil())
        let userRepoViewController = searchVC?.presentedViewController as? UserRepositoriesViewController
        userRepoViewController?.viewModel?.networkService = nil
        expect(userRepoViewController?.viewModel?.mainRepo).to(beNil())
    }
}

extension SearchViewControllerTest {
    class TestSearchViewController: SearchViewController {
        var message: String!
        var searchText: String?

        override func errorOccurred(message: String) {
            self.message = message
            super.errorOccurred(message: message)
        }

        override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            viewModel = nil
            super.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
        }

        var prepareCalled = false
        var destinationVC: UserRepositoriesViewController?

        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            prepareCalled = true
            guard let destVC = segue.destination as? UserRepositoriesViewController else {
                return
            }
            self.destinationVC = destVC
            super.prepare(for: segue, sender: sender)
        }
    }

    class TestSearchViewModel: SearchViewModel {
        var isSearchCalledWithEmptyString = false
        var isSearchCalled = false
        var isSearchCalledWithIsNewRequest = false
        override func search(isNewRequest: Bool = true) {
            isSearchCalled = true
            isSearchCalledWithEmptyString = searchText == "" ? true : false
            isSearchCalledWithIsNewRequest = isNewRequest
        }
    }
}
