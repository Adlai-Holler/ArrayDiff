
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
	public func indexPathsInSection(section: Int) -> [NSIndexPath] {
		return map { NSIndexPath(forItem: $0, inSection: section) }
	}
}

// MARK: NSIndexSet support

public extension Array {
	
	public subscript (indexes: NSIndexSet) -> [Element] {
		var result: [Element] = []
		indexes.enumerateRangesUsingBlock { range, _ in
			result += self[range.range]
		}
		return result
	}
	
	public mutating func removeAtIndexes(indexSet: NSIndexSet) {
		indexSet.enumerateRangesWithOptions(.Reverse) { range, _ in
			self.removeRange(range.range)
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
