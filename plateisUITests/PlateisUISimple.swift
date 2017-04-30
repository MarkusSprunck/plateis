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
        
        // when
        app.otherElements.matching(identifier: "1").element(boundBy: 1).tap()
        
        // then
        XCTAssertTrue(app.otherElements["World I / Level 1"].exists)
        
        // when
        app.buttons["Levels"].tap()
        app.otherElements.matching(identifier: "2").element(boundBy: 1).tap()
   
        // then
        XCTAssertTrue(app.otherElements["World I / Level 2"].exists)
        
        // when
        app.buttons["Levels"].tap()
        app.otherElements.matching(identifier: "3").element(boundBy: 1).tap()
      
        // then
        XCTAssertTrue(app.otherElements["World I / Level 3"].exists)
        
    }
    
    func testPlayGameBestNotOkAndUndo() {
        
        // when
        let app = XCUIApplication()
        app.buttons["Start"].tap()
        app.buttons["Play"].tap()
        
        // then
        XCTAssertTrue(app.otherElements["World I / Level 1"].exists)
        
        // when
        app.otherElements.matching(identifier: "38").element(boundBy: 0).tap()
        app.otherElements.matching(identifier: "48").element(boundBy: 0).tap()
        app.otherElements.matching(identifier: "6").element(boundBy: 0).tap()
        app.otherElements.matching(identifier: "66").element(boundBy: 0).tap()
        app.otherElements.matching(identifier: "22").element(boundBy: 0).tap()
        
        // then
        XCTAssertTrue(app.otherElements["Result 23.212 / Best 17.563"].exists)
        
        // when
        let undoButton = app.buttons["Undo"]
        undoButton.tap()
        undoButton.tap()
        undoButton.tap()
        undoButton.tap()
        undoButton.tap()
        
    }
    
    func testPlayGameBestOk() {
        
        // when
        let app = XCUIApplication()
        app.buttons["Start"].tap()
        app.buttons["Play"].tap()
     
        // then
        XCTAssertTrue(app.otherElements["World I / Level 1"].exists)
   
        // when
        app.otherElements.matching(identifier: "6").element(boundBy: 0).tap()
        app.otherElements.matching(identifier: "38").element(boundBy: 0).tap()
        app.otherElements.matching(identifier: "48").element(boundBy: 0).tap()
        app.otherElements.matching(identifier: "66").element(boundBy: 0).tap()
        app.otherElements.matching(identifier: "22").element(boundBy: 0).tap()
        
        // then
        XCTAssertTrue(app.otherElements["Result 17.563 / Best 17.563"].exists)
        XCTAssertTrue(app.buttons["Share"].exists)
        XCTAssertFalse(app.buttons["Undo"].exists)
        
    }
    
}
