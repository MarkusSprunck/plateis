//
//  PlateisUISimple.swift
//  plateis
//
//  Copyright © 2017 Markus Sprunck. All rights reserved.
//

import XCTest

class PlateisUISimple: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
    
        XCUIApplication().launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testStartButtonExists() {
     
        // given
        let app = XCUIApplication()
        
        // then
        XCTAssertTrue(app.buttons["Start"].exists)
   
    }
    
    func testIncrementOfHintButton() {
        
        // given
        let app = XCUIApplication()
        app.buttons["Start"].tap()
        app.buttons["Play"].tap()
    
        // then
        XCTAssertTrue(app.buttons["Hint 1"].exists)
        
        // when
        app.buttons["Hint 1"].tap()
    
        // then
        XCTAssertTrue(app.buttons["Hint 2"].exists)
        
        // when
        app.buttons["Hint 2"].tap()
  
        // then
        XCTAssertTrue(app.buttons["Hint 3"].exists)
        
        // when
        app.buttons["Levels"].tap()
    
        // then
        XCTAssertTrue(app.buttons["Play"].exists)
        XCTAssertTrue(app.buttons["Best"].exists)
        XCTAssertTrue(app.buttons["Shop"].exists)
    }
    
    func testSelectGame() {
        
        // given
        let app = XCUIApplication()
        app.buttons["Start"].tap()
        let element = app.otherElements.containing(.button, identifier:"Back").children(matching: .other).element.children(matching: .other).element
        
        // when
        element.children(matching: .other).matching(identifier: "1").element(boundBy: 1).tap()
        
        // then
        XCTAssertTrue(app.otherElements["World I / Level 1"].exists)
        
        // when
        app.buttons["Levels"].tap()
        element.children(matching: .other).matching(identifier: "2").element(boundBy: 1).tap()
   
        // then
        XCTAssertTrue(app.otherElements["World I / Level 2"].exists)
        
        // when
        app.buttons["Levels"].tap()
        element.children(matching: .other).matching(identifier: "3").element(boundBy: 1).tap()
      
        // then
        XCTAssertTrue(app.otherElements["World I / Level 3"].exists)
        
    }
}
