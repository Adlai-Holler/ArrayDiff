
import Foundation

// MARK: NSRange <-> Range<Int> conversion

public extension NSRange {
	public var range: Range<Int> {
		return location..<location+length
	}
	
	public init(range: Range<Int>) {
		location = range.startIndex
		length = range.endIndex - range.startIndex
	}
}

// MARK: NSIndexSet -> [NSIndexPath] conversion

public extension NSIndexSet {
	/**
	Returns an array of NSIndexPaths that correspond to these indexes in the given section.
	
	When reporting changes to table/collection view, you can improve performance by sorting
	deletes in descending order and inserts in ascending order.
	*/
	public func indexPathsInSection(section: Int, ascending: Bool = true) -> [NSIndexPath] {
		var result: [NSIndexPath] = []
		result.reserveCapacity(count)
		enumerateIndexesWithOptions(ascending ? [] : .Reverse) { index, _ in
			result.append(NSIndexPath(indexes: [section, index], length: 2))
		}
		return result
	}
}

// MARK: NSIndexSet support

public extension Array {
	
	public subscript (indexes: NSIndexSet) -> [Element] {
		var result: [Element] = []
		result.reserveCapacity(indexes.count)
		indexes.enumerateRangesUsingBlock { nsRange, _ in
			result += self[nsRange.range]
		}
		return result
	}
	
	public mutating func removeAtIndexes(indexSet: NSIndexSet) {
		indexSet.enumerateRangesWithOptions(.Reverse) { nsRange, _ in
			self.removeRange(nsRange.range)
		}
	}
	
	public mutating func insertElements(newElements: [Element], atIndexes indexes: NSIndexSet) {
		assert(indexes.count == newElements.count)
		var i = 0
		indexes.enumerateRangesUsingBlock { range, _ in
			self.insertContentsOf(newElements[i..<i+range.length], at: range.location)
			i += range.length
		}
	}
}
