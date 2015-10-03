//
//  ViewController.swift
//  ArrayDiffExample
//
//  Created by Adlai Holler on 10/1/15.
//  Copyright © 2015 Adlai Holler. All rights reserved.
//

import UIKit
import ArrayDiff

private let cellID = "cellID"

class ViewController: UITableViewController {
	let dataSource = ThrashingDataSource()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		title = "ArrayDiff Demo"
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Update", style: .Plain, target: self, action: "updateTapped")
		dataSource.registerReusableViewsWithTableView(tableView)
		tableView?.dataSource = dataSource
	}
	
	@objc private func updateTapped() {
		dataSource.enqueueRandomUpdate(tableView)
	}
	
}

private func createRandomSections(count: Int) -> [Section] {
	return (0..<count).map { _ in createRandomSection(50) }
}

private func createRandomSection(count: Int) -> Section {
	return Section(title: .random(), items: createRandomItems(count))
}

private func createRandomItems(count: Int) -> [String] {
	return (0..<count).map { _ in .random() }
}

struct Section {
	var title: String
	var items: [String]
	
	static func arrayDescription(sections: [Section]) -> String {
		let countsStr = sections.enumerate().map { "[\($0): \($1.items.count)]" }.joinWithSeparator(", ")
		return "<sectionCount: \(sections.count) itemCounts: \(countsStr)>"
	}
}

final class ThrashingDataSource: NSObject, UITableViewDataSource {
	// This is only modified on the update queue
	var data: [Section]

	static var updateLogging = false
	let updateQueue: NSOperationQueue
	
	// The probability of each incremental update.
	var fickleness: Float = 0.1
	
	override init() {
		updateQueue = NSOperationQueue()
		updateQueue.maxConcurrentOperationCount = 1
		updateQueue.qualityOfService = .UserInitiated
		
		let initialSectionCount = 20
		data = createRandomSections(initialSectionCount)
		super.init()
		updateQueue.name = "\(self).updateQueue"
	}
	
	func enqueueRandomUpdate(tableView: UITableView) {
		updateQueue.addOperationWithBlock { [weak self] in
			self?.executeRandomUpdate(tableView)
		}
	}
	
	private func executeRandomUpdate(tableView: UITableView) {
		var newData = data
		if ThrashingDataSource.updateLogging {
			print("Data before update: \(Section.arrayDescription(newData))")
		}
		let _deletedItems: [NSIndexSet] = (0..<newData.count).map { section in
			let indexSet = NSIndexSet.randomIndexesInRange(0..<newData.count, probability: fickleness)
			newData[section].items.removeAtIndexes(indexSet)
			return indexSet
		}
		let _deletedSections = NSIndexSet.randomIndexesInRange(0..<newData.count, probability: fickleness)
		newData.removeAtIndexes(_deletedSections)
		
		let _insertedSections = NSIndexSet.randomIndexesInRange(0..<newData.count, probability: fickleness)
		let newSections = createRandomSections(_insertedSections.count)
		newData.insertElements(newSections, atIndexes: _insertedSections)
		for (i, index) in _insertedSections.enumerate() {
			assert(newData[index].title == newSections[i].title)
		}
		
		let _insertedItems: [NSIndexSet] = (0..<newData.count).map { section in
			let indexSet = NSIndexSet.randomIndexesInRange(0..<newData.count, probability: fickleness)
			let newItems = createRandomItems(indexSet.count)
			newData[section].items.insertElements(newItems, atIndexes: indexSet)
			assert(newData[section].items[indexSet] == newItems)
			return indexSet
		}
		
		if ThrashingDataSource.updateLogging {
			print("Data after update: \(Section.arrayDescription(newData))")
		}
		let sectionDiff = data.diff(newData, elementsAreEqual: { $0.title == $1.title })
		// diffs will exist for all sections that weren't deleted or inserted
		let itemDiffs: [ArrayDiff?] = data.enumerate().map { oldSection, info in
			if let newSection = sectionDiff.newIndexForOldIndex(oldSection) {
				assert(newData[newSection].title == info.title, "Diffing for the wrong section!")
				return data[oldSection].items.diff(newData[newSection].items)
			} else {
				return nil
			}
		}
		
		// Assert that the diffing worked
		assert(_insertedSections == sectionDiff.insertedIndexes)
		assert(_deletedSections == sectionDiff.removedIndexes)
		for (oldSection, diffOrNil) in itemDiffs.enumerate() {
			if let diff = diffOrNil {
				assert(_deletedItems[oldSection] == diff.removedIndexes)
				if let newSection = sectionDiff.newIndexForOldIndex(oldSection) {
					assert(_insertedItems[newSection] == diff.insertedIndexes)
				} else {
					assertionFailure("Found an item diff for a section that was removed. Wat.")
				}
			}
		}
		
		dispatch_sync(dispatch_get_main_queue()) {
			tableView.beginUpdates()
			self.data = newData
			if sectionDiff.removedIndexes.count > 0 {
				tableView.deleteSections(sectionDiff.removedIndexes, withRowAnimation: .Automatic)
			}
			if sectionDiff.insertedIndexes.count > 0 {
				tableView.insertSections(sectionDiff.insertedIndexes, withRowAnimation: .Automatic)
			}
			for (oldSection, diffOrNil) in itemDiffs.enumerate() {
				if let diff = diffOrNil {
					tableView.deleteRowsAtIndexPaths(diff.removedIndexes.indexPathsInSection(oldSection), withRowAnimation: .Automatic)
					if let newSection = sectionDiff.newIndexForOldIndex(oldSection) {
						tableView.insertRowsAtIndexPaths(diff.insertedIndexes.indexPathsInSection(newSection), withRowAnimation: .Automatic)
					} else {
						assertionFailure("Found an item diff for a section that was removed. Wat.")
					}
				}
			}
			tableView.endUpdates()
		}
	}
	
	func registerReusableViewsWithTableView(tableView: UITableView) {
		tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellID)
	}
	
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return data[section].title
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath)
		cell.textLabel?.text = data[indexPath.section].items[indexPath.item]
		return cell
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return data[section].items.count
	}
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return data.count
	}
}

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
