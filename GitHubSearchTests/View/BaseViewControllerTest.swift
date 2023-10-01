//
//  BaseViewControllerTest.swift
//  GitHubSearchTests
//
//  Created by Yevhen Mekhedov on 07.02.2020.
//  Copyright © 2020 Yevhen Mekhedov. All rights reserved.
//

import XCTest
import GHNetwork
import MagicalRecord
import Nimble

@testable import GitHubSearch

class BaseViewControllerTest: XCTestCase {
    override static func setUp() {
        super.setUp()
        MagicalRecord.setDefaultModelFrom(self.classForCoder())
        MagicalRecord.cleanUp()
        MagicalRecord.setupCoreDataStackWithInMemoryStore()
    }

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        Repositories.mr_truncateAll()
        UserRepositories.mr_truncateAll()
    }

    override static func tearDown() {
        super.tearDown()
        MagicalRecord.cleanUp()
    }

    var tableView: UITableView!
    var testViewModelDelegate: TestViewModelDelegate!

    func initialSetup<ViewModel: ViewModelProtocol>(viewModel: ViewModel) -> BaseViewController<ViewModel> {
        let baceViewController = BaseViewController<ViewModel>()

        tableView = UITableView()
        tableView.delegate = baceViewController
        tableView.dataSource = baceViewController

        testViewModelDelegate = TestViewModelDelegate()
        testViewModelDelegate.tableView = tableView
        viewModel.delegate = testViewModelDelegate

        baceViewController.viewModel = viewModel
        return baceViewController
    }

    func tableViewNumberOfRowsInSectionForEntity<EntityType: RepositoriesProtocol, PropertyForKeyPath>( sortDescriptorKeyPath: KeyPath<EntityType, PropertyForKeyPath>, shouldReturn: Int) -> Int {
        let testViewModel = TestViewModel<EntityType>()
        let baceViewController = initialSetup(viewModel: testViewModel)
        for _ in 0..<shouldReturn {
            _ = EntityType.mr_createEntity()
        }
        NSManagedObjectContext.mr_default().mr_saveOnlySelfAndWait()
        let numberOfRowsInSection = baceViewController.tableView(tableView, numberOfRowsInSection: 0)
        return numberOfRowsInSection
    }

    func test_tableViewNumberOfRowsInSectionForRepositoriesEntity_shouldReturn4() {
        let numberOfRows = tableViewNumberOfRowsInSectionForEntity(sortDescriptorKeyPath: \Repositories.stars, shouldReturn: 4)
        expect(numberOfRows).to(equal(4))
    }

    func test_tableViewNumberOfRowsInSectionForRepositoryEntity_shouldReturn0() {
        let numberOfRows = tableViewNumberOfRowsInSectionForEntity(sortDescriptorKeyPath: \Repositories.stars, shouldReturn: 0)
        expect(numberOfRows).to(equal(0))
    }

    func test_tableViewNumberOfRowsInSectionForUserRepositoriesEntity_shouldReturn4() {
        let numberOfRows = tableViewNumberOfRowsInSectionForEntity(sortDescriptorKeyPath: \UserRepositories.stars, shouldReturn: 4)
        expect(numberOfRows).to(equal(4))
    }

    func test_tableViewNumberOfRowsInSectionForUserRepositoriesEntity_shouldReturn0() {
        let numberOfRows = tableViewNumberOfRowsInSectionForEntity(sortDescriptorKeyPath: \UserRepositories.stars, shouldReturn: 0)
        expect(numberOfRows).to(equal(0))
    }

    func test_tableViewNumberOfRowsInSection_ShouldReturn0() {
        let baseViewController = initialSetup(viewModel: TestViewModel<Repositories>())
        baseViewController.viewModel = nil
        let numberOfRows = baseViewController.tableView(tableView, numberOfRowsInSection: 0)
        expect(numberOfRows).to(equal(0))
    }

    func test_CellForRow_ReturnFilledCell() {
        let baseViewController = initialSetup(viewModel: TestViewModel<Repositories>())
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        let repoWithLongName = Repositories.mr_createEntity()
        repoWithLongName?.name = "the-swift-programming-language-guide"
        repoWithLongName?.fullName = "asdasd"
        repoWithLongName?.id = 1
        repoWithLongName?.stars = 32
        NSManagedObjectContext.mr_default().mr_saveOnlySelfAndWait()
        let repoNameAfterCroppingCorrect = "the-swift-programming-language..."
        NSManagedObjectContext.mr_default().mr_saveOnlySelfAndWait()
        let cell = baseViewController.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0))
        expect(cell.textLabel?.text).to(match(repoNameAfterCroppingCorrect))
    }

    func test_DidSelectRowAt_shouldDeselectCell() {
        //Repositories.sortDescriptors = [NSSortDescriptor(keyPath: \Repositories.stars, ascending: false)]
        let viewModel = TestViewModel<Repositories>()
        let baseViewController = initialSetup(viewModel: viewModel)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        let repoWithLongName = Repositories.mr_createEntity()
        repoWithLongName?.name = "the-swift-programming-language-guide"
        repoWithLongName?.fullName = "asdasd"
        repoWithLongName?.id = 1
        repoWithLongName?.stars = 32
        NSManagedObjectContext.mr_default().mr_saveOnlySelfAndWait()
        //baseViewController.tableView?(tableView, willSelectRowAt: IndexPath(row: 0, section: 0))
        var cell = baseViewController.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0))
        cell.isSelected = true
        baseViewController.tableView(tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        cell = baseViewController.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0))
        expect(cell.isSelected).to(beFalse())
    }

    func test_WillDisplayCell_shouldNotCallSearch() {
        //Repositories.sortDescriptors = [NSSortDescriptor(keyPath: \Repositories.stars, ascending: false)]
        let viewModel = TestViewModel<Repositories>(callPerformFetch: false)
        let baseViewController = initialSetup(viewModel: viewModel)
        baseViewController.tableView(tableView, willDisplay: UITableViewCell(), forRowAt: IndexPath(row: 0, section: 0))
        expect(viewModel.isSearchCalled).to(beFalse())
    }

    func test_tableViewWillDisplayCell_ShouldNotCallSearchIfModelEmpty() {
        //Repositories.sortDescriptors = [NSSortDescriptor(keyPath: \Repositories.stars, ascending: false)]
        let viewModel = TestViewModel<Repositories>(callPerformFetch: false)
        let baseViewController = initialSetup(viewModel: viewModel)
        baseViewController.viewModel = nil
        baseViewController.tableView(tableView, willDisplay: UITableViewCell(), forRowAt: IndexPath(row: 0, section: 0))
        expect(viewModel.isSearchCalled).to(beFalse())

    }

    func test_tableViewWillDisplayCell_ShouldCallSearchWithEmptyString() {
        let searchViewModel = SearchViewModelMock()
        let baseViewController = initialSetup(viewModel: searchViewModel)

        let repoWithLongName = Repositories.mr_createEntity()
        repoWithLongName?.name = "the-swift-programming-language-guide"
        repoWithLongName?.fullName = "asdasd"
        repoWithLongName?.stars = 32
        repoWithLongName?.id = 1
        NSManagedObjectContext.mr_default().mr_saveOnlySelfAndWait()

        baseViewController.tableView(tableView, willDisplay: UITableViewCell(), forRowAt: IndexPath(row: 0, section: 0))
        expect(searchViewModel.isSearchCalledWithEmptyString).to(beTrue())
    }
}

extension BaseViewControllerTest {
    class TestViewModel<Entity: RepositoriesProtocol>: RepositoriesViewModel<Entity> {
        init(callPerformFetch: Bool = true) {
            super.init()
            if callPerformFetch {
                do {
                    try fetchedResultsController.performFetch()
                } catch _ {
                    print("ERROR!")
                }
            }
        }

        var isSearchCalled = false
        override func search(isNewRequest: Bool = true) {
            isSearchCalled = true
        }
    }

    class SearchViewModelMock: SearchViewModel {
        var isSearchCalledWithEmptyString = false
        override func search(isNewRequest: Bool = true) {
            isSearchCalledWithEmptyString = searchText == "" ? true : false
        }
    }

    class TestViewModelDelegate: ViewModelDelegate, FetchedResultsViewModelDelegate {

        var tableView: UITableView!
        // MARK: - ViewModelDelegate
        @objc func errorOccurred(message: String) {
        }

        @objc func willStartFetchingItems() {
        }

        @objc func didFinishFetchingItems() {
        }

        // MARK: - NSFetchedResultsControllerDelegate
        func controllerWillChangeContent() {
          tableView.beginUpdates()
        }

        func controllerDidChangeObject(at indexPath: IndexPath?,
                                       for type: NSFetchedResultsChangeType,
                                       newIndexPath: IndexPath?) {
            switch type {
            case .insert:
                tableView.insertRows(at: [newIndexPath!], with: .automatic)
            case .delete:
                tableView.deleteRows(at: [indexPath!], with: .automatic)
            case .update:
                tableView.reloadRows(at: [indexPath!], with: .automatic)
            case .move:
                tableView.deleteRows(at: [indexPath!], with: .automatic)
                tableView.insertRows(at: [newIndexPath!], with: .automatic)
            @unknown default:
                print("DEFAULT BEHAVIOUR!")
            }
        }

        func controllerDidChangeContent() {
          tableView.endUpdates()
        }
    }
}
