//
//  ModelTests.swift
//  PLATEISTests
//
//  Created by Markus Sprunck on 07/07/16.
//  Copyright © 2016 Markus Sprunck. All rights reserved.
//


import XCTest
@testable import PLATEIS

class ModelTests: XCTestCase {
    
    func testModel_add_two_nodes() {
        // given
        let model = Model(world: "world test", name: "test1", rows: 1, cols: 2)
        
        // when
        model.addNode(Node(x:1, y:7, active: false))
        model.addNode(Node(x:3, y:8, active: false))
        
        // then
        assert(2 == model.count())
    }
    
    func testModel_get_two_nodes() {
        // given
        let model = Model(world: "world test", name: "test2", rows: 1, cols: 2)
        model.addNode(Node(x:1, y:7, active: false))
        model.addNode(Node(x:3, y:8, active: false))
        
        // when
        let node1 = model.getNode(0)
        let node2 = model.getNode(1)
        node2.setActive(true)
        
        // then
        assert(1 == node1.x)
        assert(7 == node1.y)
        assert(!node1.isActive())
        assert(3 == node2.x)
        assert(8 == node2.y)
        assert(node2.isActive())
    }
    
    func testDecoder() {
        
        // given
        let path = NSTemporaryDirectory() as NSString
        let locToSave = path.appending("tests_model")
        print("node_locToSave=\(locToSave)")
        
        // when
        let model = Model(world: "world test", name: "test2", rows: 1, cols: 2)
        model.addNode(Node(x:1, y:7, active: false))
        model.addNode(Node(x:3, y:8, active: false))
        NSKeyedArchiver.archiveRootObject([model], toFile: locToSave)
        let data = NSKeyedUnarchiver.unarchiveObject(withFile: locToSave) as? [Model]
        
        // then
        XCTAssertNotNil(data)
        XCTAssertEqual(data!.count, 1)
        XCTAssertEqual(data!.first?.getName(), "test2")
        XCTAssertEqual(data!.first?.getRows(), 1)
        XCTAssertEqual(data!.first?.getCols(), 2)
        XCTAssertEqual(data!.first?.getNode(0).x, 1)
        XCTAssertEqual(data!.first?.getNode(0).y, 7)
        XCTAssertEqual(data!.first?.getNode(0).isActive(), false)
        XCTAssertEqual(data!.first?.getNode(1).x, 3)
        XCTAssertEqual(data!.first?.getNode(1).y, 8)
        XCTAssertEqual(data!.first?.getNode(1).isActive(), false)
    }
   
}
