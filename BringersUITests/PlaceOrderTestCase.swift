//
//  PlaceOrderTestCase.swift
//  BringersUITests
//
//  Created by Keith C on 3/5/22.
//

import XCTest

class PlaceOrderTestCase: XCTestCase {
    
    func testCheckPlaceOrderButtonExist() throws {
        
        let app = XCUIApplication()
        app.launch()
        
        sleep(5)
        
        let button = app.buttons["Place Order Place Order Button"]
        XCTAssertTrue(button.exists)
    }
}
