//
//  BaseViewModelTest.swift
//  GitHubSearchTests
//
//  Created by Yevhen Mekhedov on 29.01.2020.
//  Copyright © 2020 Yevhen Mekhedov. All rights reserved.
//

import XCTest
import Nimble
import MagicalRecord
import GHNetwork

@testable import GitHubSearch
class BaseViewModelTest: XCTestCase {

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
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        //Repositories.mr_truncateAll()
       // try? NSManagedObjectContext.mr_default().save()
        Repositories.mr_truncateAll()
        UserRepositories.mr_truncateAll()
        //NSManagedObjectContext.mr_default().mr_saveOnlySelfAndWait()
    }

    override class func tearDown() {
        super.tearDown()
        MagicalRecord.cleanUp()
    }

    func test_ImportToEntity_checkIfAllObjectsWereSaved() {
        //Repositories.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let baseViewModel = BaseViewModel<Repositories>()
        var fakeItems: [GHItem] = []
        for counter in 0...3 {
            let fakeItem = FakeItem(name: "fakeName\(counter)",
                fullName: "fullName\(counter)",
                id: Int(counter + 1),
                stars: counter,
                ownerName: "OwnerName")
            fakeItems.append(fakeItem)
        }
        var countItemsInDB: UInt = 0
        waitUntil(timeout: 5, action: { (done) in
            baseViewModel.importToEntity(items: fakeItems) { (_) in
                countItemsInDB = Repositories.mr_countOfEntities()
                expect(countItemsInDB).to(equal(4))
                done()
            }
        })
//        baseViewModel.importToEntity(items: fakeItems) { (_) in
//        }
//        expect(Repositories.mr_countOfEntities()).toEventually(equal(4), timeout: 10)
    }
}

extension BaseViewModelTest {
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
}
