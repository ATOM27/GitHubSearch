//
//  CellTest.swift
//  GitHubSearchTests
//
//  Created by Yevhen Mekhedov on 29.01.2020.
//  Copyright © 2020 Yevhen Mekhedov. All rights reserved.
//

import XCTest
import GHNetwork
import MagicalRecord
import Nimble

@testable import GitHubSearch
class CellTest: XCTestCase {

    var tableView: UITableView!

    override class func setUp() {
        super.setUp()
        MagicalRecord.setDefaultModelFrom(self.classForCoder())
        MagicalRecord.cleanUp()
        MagicalRecord.setupCoreDataStackWithInMemoryStore()
    }

    override class func tearDown() {
        super.tearDown()
        MagicalRecord.cleanUp()
    }
    override func setUp() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
         // swiftlint:disable:next force_cast
        let controller = storyboard.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
        _ = controller.view

        tableView = controller.tableView
        let dataSource = FakeDataSource()
        tableView?.dataSource = dataSource
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        tableView = nil
    }

    func test_HasTextLabel() {
        let cell = tableView?.dequeueReusableCell(withIdentifier: "Cell", for: IndexPath(row: 0, section: 0))
        expect(cell?.textLabel).toNot(beNil())
    }

    func test_HasDetailedLabel() {
        let cell = tableView?.dequeueReusableCell(withIdentifier: "Cell", for: IndexPath(row: 0, section: 0))
        expect(cell?.detailTextLabel).toNot(beNil())
    }
}

extension CellTest {
    class FakeDataSource: NSObject, UITableViewDataSource {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 1
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            return cell
        }
    }
}
