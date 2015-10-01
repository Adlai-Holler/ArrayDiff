//
//  ArrayDiffTests.swift
//  ArrayDiffTests
//
//  Created by Adlai Holler on 10/1/15.
//  Copyright © 2015 Adlai Holler. All rights reserved.
//

import XCTest
@testable import ArrayDiff

class ArrayDiffTests: XCTestCase {
	
    func testACommonCase() {
		let old = "a b c d e".componentsSeparatedByString(" ")
		let new = "m a b f".componentsSeparatedByString(" ")
		
		let allFirstIndexes = NSIndexSet(indexesInRange: NSMakeRange(0, old.count))
		
		let expectedRemoves = NSMutableIndexSet()
		expectedRemoves.addIndexesInRange(NSMakeRange(2, 3))

		let expectedInserts = NSMutableIndexSet()
		expectedInserts.addIndex(0)
		expectedInserts.addIndex(3)
		

		let expectedCommonObjects = "a b".componentsSeparatedByString(" ")

		let diff = old.diff(new)
		
		XCTAssertEqual(expectedInserts, diff.insertedIndexes)
		XCTAssertEqual(expectedRemoves, diff.removedIndexes)
		XCTAssertEqual(expectedCommonObjects, old[diff.commonIndexes])
		
		let removedPlusCommon = NSMutableIndexSet(indexSet: diff.removedIndexes)
		removedPlusCommon.addIndexes(diff.commonIndexes)
		XCTAssertEqual(removedPlusCommon, allFirstIndexes)
		
		var reconstructed = old
		reconstructed.removeAtIndexes(diff.removedIndexes)
		reconstructed.insertElements(new[diff.insertedIndexes], atIndexes: diff.insertedIndexes)
		XCTAssertEqual(reconstructed, new)
    }
    
}
