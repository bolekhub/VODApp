//
//  VideModelTest.swift
//  VODAppTests
//
//  Created by Boris Chirino on 26/07/2019.
//  Copyright © 2019 Home. All rights reserved.
//

import XCTest
@testable import VODApp

class VideModelTest: XCTestCase, PlayListViewModelEvents {
    
    func didUpdate() {
        
        XCTAssertTrue(self.viewModel?.items.count == 4)
    }
    
    private var viewModel: PlayListViewModel?

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let dataStore = VideoDataStore(usingDAO: CoreDataDAO())
        viewModel = PlayListViewModel(dataStore: dataStore)
        viewModel?.delegate = self
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        XCTAssertNotNil(viewModel)
        self.viewModel?.fetchData()
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
