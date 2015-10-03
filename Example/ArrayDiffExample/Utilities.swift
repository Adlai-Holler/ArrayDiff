
import UIKit

extension NSIndexSet {
	// Get a random index set in a range
	static func randomIndexesInRange(range: Range<Int>, probability: Float) -> NSIndexSet {
		let result = NSMutableIndexSet()
		for i in range {
			if Bool.random(probability) {
				result.addIndex(i)
			}
		}
		return result
	}
}

extension Bool {
	static var trueCount = 0
	static var totalCount = 0
	static func random(probability: Float) -> Bool {
		let result = arc4random_uniform(100) < UInt32(probability * 100)
		if result {
			trueCount++
		}
		totalCount++
		return result
	}
}

extension String {
	static func random() -> String {
		return NSUUID().UUIDString
	}
}
