//
//  VODAppTests.swift
//  VODAppTests
//
//  Created by Boris Chirino on 22/07/2019.
//  Copyright © 2019 Home. All rights reserved.
//

import XCTest
@testable import VODApp

class VODAppTests: XCTestCase {

    private let bundle = Bundle.main
    private let jsonPlayListFileName = "playlist"
    private var jsonDecoder = JSONDecoder.init()
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testParseFromJsonFile() {
        let jsonUrl = bundle.url(forResource: jsonPlayListFileName, withExtension: "json")
        XCTAssertNotNil(jsonUrl, "Probably json file are missing ?")
        
        do {
            
            let playListItemsData = try Data.init(contentsOf: jsonUrl!)
            XCTAssertNotNil(playListItemsData)
            let parsedJson  = try JSONSerialization.jsonObject(with: playListItemsData,
                                                               options: .allowFragments) as? NSDictionary
            XCTAssertNotNil(parsedJson)

            let playListItemsDictionary = parsedJson?["playlist"] as? NSDictionary
            XCTAssertNotNil(playListItemsDictionary)
            XCTAssertEqual(playListItemsDictionary?.allKeys.count, 5)
            
            for (k, v) in playListItemsDictionary!  {
                let item = PlayListItemVO.fromDictionary(v as! NSDictionary, identifier: k as! String)
                XCTAssertNotNil(item)
                XCTAssertEqual(item?.id, k as? String)
                XCTAssertNotNil(item?.sourceURL())
            }
            
        } catch {
            
            XCTFail(error.localizedDescription)
        }
    }
    
    func testPlayListItemsEqualityAndHash() {
        
        let pli1 = PlayListItemVO(title: "test1", subtitle: "subtitle2", url: "https://fake.com", id: "abc123")
        let pli2 = PlayListItemVO(title: "test1", subtitle: "subtitle2", url: "https://fake.com", id: "1233abc")
        let pli3 = PlayListItemVO(title: "my live", subtitle: "hot people", url: "https://fake.com", id: "abc123")

        XCTAssertEqual(pli1, pli3)
        XCTAssertNotEqual(pli1, pli2)
        
        var collection = Set<PlayListItemVO>()
        collection.update(with: pli1)
        collection.update(with: pli2)
        collection.update(with: pli3)
        
        XCTAssertEqual(collection.count, 2)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
