//
//  RepositoriesViewModelTest.swift
//  GitHubSearchTests
//
//  Created by Yevhen Mekhedov on 10.02.2020.
//  Copyright © 2020 Yevhen Mekhedov. All rights reserved.
//

import XCTest
import MagicalRecord
import GHNetwork
import Nimble

@testable import GitHubSearch
class RepositoriesViewModelTest: XCTestCase {

    override class func setUp() {
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

    override class func tearDown() {
        super.tearDown()
        MagicalRecord.cleanUp()
    }

    func initialSetup<Entity: RepositoriesProtocol>() -> RepositoriesViewModel<Entity> {
        let repositoriesViewModel = RepositoriesViewModel<Entity>()
        try? repositoriesViewModel.fetchedResultsController.performFetch()
        return repositoriesViewModel
    }

    func test_repositpriesViewModelFetchResult_shoulBeNotNil() {
        let repViewModel: RepositoriesViewModel<Repositories> = initialSetup()
        expect(repViewModel.fetchedResultsController.delegate).toNot(beNil())
        expect(repViewModel.fetchedResultsController.delegate).to(beIdenticalTo(repViewModel))
    }

    func test_search_shouldFatalError() {
        let repViewModel: RepositoriesViewModel<Repositories> = initialSetup()
        expect { repViewModel.search(isNewRequest: false) }.to(throwAssertion())
    }

    func test_getRepositoryNameWithEmptyString_ShouldReturnEmptyString() {
        let repViewModel: RepositoriesViewModel<Repositories> = initialSetup()

        let repoWithLongName = Repositories.mr_createEntity()

        repoWithLongName?.fullName = "asdasd"
        repoWithLongName?.id = 1
        repoWithLongName?.stars = 32
        NSManagedObjectContext.mr_default().mr_saveOnlySelfAndWait()

        let name = repViewModel.getRepositoryName(IndexPath(row: 0, section: 0))
        expect(name).to(equal(""))
    }

    func test_getRepositoryName_ShouldReturnNameLessThan30Characters() {
        let repViewModel: RepositoriesViewModel<Repositories> = initialSetup()
        let repoWithLongName = Repositories.mr_createEntity()
        repoWithLongName?.name = "the-swift-programming-language-guide"
        repoWithLongName?.fullName = "asdasd"
        repoWithLongName?.id = 1
        repoWithLongName?.stars = 32
        NSManagedObjectContext.mr_default().mr_saveOnlySelfAndWait()
        let repoNameAfterCroppingCorrect = "the-swift-programming-language..."
        let repoNameAfterCroppingTest = repViewModel.getRepositoryName(IndexPath(row: 0, section: 0))
        expect(repoNameAfterCroppingTest).to(match(repoNameAfterCroppingCorrect))
    }

    func test_getRepoStars_ShouldReturnStars() {
        let repViewModel: RepositoriesViewModel<Repositories> = initialSetup()
        let repoStars = Repositories.mr_createEntity()
        repoStars?.stars = 43
        NSManagedObjectContext.mr_default().mr_saveOnlySelfAndWait()
        let repoReturnStarsCorrect = "43"
        let repoResturnStarsTest = repViewModel.getRepoStars(IndexPath(row: 0, section: 0))
        expect(repoResturnStarsTest).toEventually(match(repoReturnStarsCorrect), timeout: 5)
    }

    func test_ShouldCallControllerWillChangeContent() {
        let repViewModel: RepositoriesViewModel<Repositories> = initialSetup()
        let viewModelDelegate = SearchViewModelTest.SearchViewModelMockDelegate()
        repViewModel.delegate = viewModelDelegate
        let repoWithLongName = Repositories.mr_createEntity()
        repoWithLongName?.name = "the-swift-programming-language-guide"
        repoWithLongName?.fullName = "asdasd"
        repoWithLongName?.id = 1
        repoWithLongName?.stars = 32
        NSManagedObjectContext.mr_default().mr_saveOnlySelfAndWait()
        expect(viewModelDelegate.isControllerWillChangeConttentCalled).to(beTrue())
    }

    func test_ShouldCallControllerDidChangeObject() {
        let repViewModel: RepositoriesViewModel<Repositories> = initialSetup()
        let viewModelDelegate = SearchViewModelTest.SearchViewModelMockDelegate()
        repViewModel.delegate = viewModelDelegate
        let repoWithLongName = Repositories.mr_createEntity()
        repoWithLongName?.name = "the-swift-programming-language-guide"
        repoWithLongName?.fullName = "asdasd"
        repoWithLongName?.id = 1
        repoWithLongName?.stars = 32
        NSManagedObjectContext.mr_default().mr_saveOnlySelfAndWait()
        expect(viewModelDelegate.isControllerDidChangeObjectCalled).to(beTrue())
    }

    func test_ShouldCallControllerDidChangeContent() {
        let repViewModel: RepositoriesViewModel<Repositories> = initialSetup()
        let viewModelDelegate = SearchViewModelTest.SearchViewModelMockDelegate()
        repViewModel.delegate = viewModelDelegate
        let repoWithLongName = Repositories.mr_createEntity()
        repoWithLongName?.name = "the-swift-programming-language-guide"
        repoWithLongName?.fullName = "asdasd"
        repoWithLongName?.id = 1
        repoWithLongName?.stars = 32
        NSManagedObjectContext.mr_default().mr_saveOnlySelfAndWait()
        expect(viewModelDelegate.isControllerDidChangeContentCalled).to(beTrue())
    }
}
