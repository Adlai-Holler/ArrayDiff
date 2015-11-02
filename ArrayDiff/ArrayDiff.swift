
import Foundation

public struct ArrayDiff {
	static var debugLogging = false
	
	/// The indexes in the old array of the items that were kept
	public let commonIndexes: NSIndexSet
	/// The indexes in the old array of the items that were removed
	public let removedIndexes: NSIndexSet
	/// The indexes in the new array of the items that were inserted
	public let insertedIndexes: NSIndexSet
	
	/// Returns nil if the item was inserted
	public func oldIndexForNewIndex(index: Int) -> Int? {
		if insertedIndexes.containsIndex(index) { return nil }
		
		var result = index
		result -= insertedIndexes.countOfIndexesInRange(NSMakeRange(0, index))
		result += removedIndexes.countOfIndexesInRange(NSMakeRange(0, result + 1))
		return result
	}
	
	/// Returns nil if the item was deleted
	public func newIndexForOldIndex(index: Int) -> Int? {
		if removedIndexes.containsIndex(index) { return nil }
		
		var result = index
		let deletedBefore = removedIndexes.countOfIndexesInRange(NSMakeRange(0, index))
		result -= deletedBefore
		var insertedAtOrBefore = 0
		for i in insertedIndexes {
			if i <= result  {
				insertedAtOrBefore++
				result++
			} else {
				break
			}
		}
		if ArrayDiff.debugLogging {
			print("***Old -> New\n Removed \(removedIndexes)\n Inserted \(insertedIndexes)\n \(index) - \(deletedBefore) + \(insertedAtOrBefore) = \(result)\n")
		}
		
		return result
	}
    
    /**
     Returns true iff there are no changes to the items in this diff
     */
    public var isEmpty: Bool {
        return removedIndexes.count == 0 && insertedIndexes.count == 0
    }
}

public extension Array {
	
	public func diff(other: Array<Element>, elementsAreEqual: ((Element, Element) -> Bool)) -> ArrayDiff {
		var lengths: [[Int]] = Array<Array<Int>>(
			count: count + 1,
			repeatedValue: Array<Int>(
				count: other.count + 1,
				repeatedValue: 0)
		)
		
		for var i = count; i >= 0; i-- {
			for var j = other.count; j >= 0; j-- {
				if i == count || j == other.count {
					lengths[i][j] = 0
				} else if elementsAreEqual(self[i], other[j]) {
					lengths[i][j] = 1 + lengths[i+1][j+1]
				} else {
					lengths[i][j] = max(lengths[i+1][j], lengths[i][j+1])
				}
			}
		}
		let commonIndexes = NSMutableIndexSet()
		
		for var i = 0, j = 0; i < count && j < other.count; {
			if elementsAreEqual(self[i], other[j]) {
				commonIndexes.addIndex(i)
				i++
				j++
			} else if lengths[i+1][j] >= lengths[i][j+1] {
				i++
			} else {
				j++
			}
		}
		
		let removedIndexes = NSMutableIndexSet(indexesInRange: NSMakeRange(0, count))
		removedIndexes.removeIndexes(commonIndexes)
		
		let commonObjects = self[commonIndexes]
		let addedIndexes = NSMutableIndexSet()
		for var i = 0, j = 0; i < commonObjects.count || j < other.count; {
			if i < commonObjects.count && j < other.count && elementsAreEqual (commonObjects[i], other[j]) {
				i++
				j++
			} else {
				addedIndexes.addIndex(j)
				j++
			}
		}
		
		return ArrayDiff(commonIndexes: commonIndexes, removedIndexes: removedIndexes, insertedIndexes: addedIndexes)
	}
}

public extension Array where Element: Equatable {
	public func diff(other: Array<Element>) -> ArrayDiff {
		return self.diff(other, elementsAreEqual: { $0 == $1 })
	}
}
