//
//  NodeTests.swift
//  PLATEISTests
//
//  Created by Markus Sprunck on 07/07/16.
//  Copyright © 2016 Markus Sprunck. All rights reserved.
//

import XCTest
@testable import PLATEIS

class NodeTests: XCTestCase {
    
    func test_node_default_not_active() {
        // given
        let node = Node(x:3, y:8, active: false)
        
        // when
        
        // then
        assert(!node.isActive())
    }
    
    func test_node_active() {
        // given
        let node = Node(x:3, y:8, active: false)
        
        // when
        node.setActive( true )
        
        // then
        assert(node.isActive())
    }
    
    func testDecoder() {
     
        // given
        let path = NSTemporaryDirectory() as NSString
        let locToSave = path.stringByAppendingString("tests_node")
        print("node_locToSave=\(locToSave)")
      
        // when
        let newNode = Node(x:3, y:8, active: false)
        NSKeyedArchiver.archiveRootObject([newNode], toFile: locToSave)
        let data = NSKeyedUnarchiver.unarchiveObjectWithFile(locToSave) as? [Node]
   
        // then
        XCTAssertNotNil(data)
        XCTAssertEqual(data!.count, 1)
        XCTAssertEqual(data!.first?.x, 3)
        XCTAssertEqual(data!.first?.y, 8)
        XCTAssertEqual(data!.first?.active, false)
    }
    
}
