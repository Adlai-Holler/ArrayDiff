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
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "+100", style: .Plain, target: self, action: "updateTapped")
		dataSource.registerReusableViewsWithTableView(tableView)
		tableView?.dataSource = dataSource
	}
	
	@objc private func updateTapped() {
		for _ in 0..<100 {
			dataSource.enqueueRandomUpdate(tableView, completion: { dataSource in
				let operationCount = dataSource.updateQueue.operationCount
				self.title = operationCount > 0 ? String(operationCount) : "ArrayDiff Demo"
			})
		}
	}
	
}

private func createRandomSections(count: Int) -> [BasicSection<String>] {
	return (0..<count).map { _ in createRandomSection(20) }
}

private func createRandomSection(count: Int) -> BasicSection<String> {
	return BasicSection(name: .random(), items: createRandomItems(count))
}

private func createRandomItems(count: Int) -> [String] {
	return (0..<count).map { _ in .random() }
}

final class ThrashingDataSource: NSObject, UITableViewDataSource {
	// This is only modified on the update queue
	var data: [BasicSection<String>]

	static var updateLogging = false
	let updateQueue: NSOperationQueue
	
	// The probability of each incremental update.
	var fickleness: Float = 0.1
	
	override init() {
		updateQueue = NSOperationQueue()
		updateQueue.maxConcurrentOperationCount = 1
		updateQueue.qualityOfService = .UserInitiated
		
		let initialSectionCount = 5
		data = createRandomSections(initialSectionCount)
		super.init()
		updateQueue.name = "\(self).updateQueue"
	}
	
	func enqueueRandomUpdate(tableView: UITableView, completion: (ThrashingDataSource -> Void)) {
		updateQueue.addOperationWithBlock {
			self.executeRandomUpdate(tableView)
			NSOperationQueue.mainQueue().addOperationWithBlock {
				completion(self)
			}
		}
	}
	
	private func executeRandomUpdate(tableView: UITableView) {
		if ThrashingDataSource.updateLogging {
			print("Data before update: \(data.nestedDescription)")
		}
		
		var newData = data
		
		let minimumSectionCount = 3
		let minimumItemCount = 5
		
		let _deletedItems: [NSIndexSet] = newData.enumerate().map { sectionIndex, sectionInfo in
			if sectionInfo.items.count >= minimumItemCount {
				let indexSet = NSIndexSet.randomIndexesInRange(0..<sectionInfo.items.count, probability: fickleness)
				newData[sectionIndex].items.removeAtIndexes(indexSet)
				return indexSet
			} else {
				return NSIndexSet()
			}
		}
		
		let _deletedSections: NSIndexSet
		if newData.count >= minimumSectionCount {
			_deletedSections = NSIndexSet.randomIndexesInRange(0..<newData.count, probability: fickleness)
			newData.removeAtIndexes(_deletedSections)
		} else {
			_deletedSections = NSIndexSet()
		}
		
		let _insertedSections = NSIndexSet.randomIndexesInRange(0..<newData.count, probability: fickleness)
		let newSections = createRandomSections(_insertedSections.count)
		newData.insertElements(newSections, atIndexes: _insertedSections)
		for (i, index) in _insertedSections.enumerate() {
			assert(newData[index] == newSections[i])
		}
		
		let _insertedItems: [NSIndexSet] = newData.enumerate().map { sectionIndex, sectionInfo in
			let indexSet = NSIndexSet.randomIndexesInRange(0..<sectionInfo.items.count, probability: fickleness)
			let newItems = createRandomItems(indexSet.count)
			newData[sectionIndex].items.insertElements(newItems, atIndexes: indexSet)
			assert(newData[sectionIndex].items[indexSet] == newItems)
			return indexSet
		}
		
		if ThrashingDataSource.updateLogging {
			print("Data after update: \(newData.nestedDescription)")
		}
		let nestedDiff = data.diffNested(newData)
		
		// Assert that the diffing worked
		assert(_insertedSections == nestedDiff.sectionsDiff.insertedIndexes)
		assert(_deletedSections == nestedDiff.sectionsDiff.removedIndexes)
		for (oldSection, diffOrNil) in nestedDiff.itemDiffs.enumerate() {
			if let diff = diffOrNil {
				assert(_deletedItems[oldSection] == diff.removedIndexes)
				if let newSection = nestedDiff.sectionsDiff.newIndexForOldIndex(oldSection) {
					assert(_insertedItems[newSection] == diff.insertedIndexes)
				} else {
					assertionFailure("Found an item diff for a section that was removed. Wat.")
				}
			}
		}
		
		dispatch_sync(dispatch_get_main_queue()) {
			tableView.beginUpdates()
			self.data = newData
			nestedDiff.applyToTableView(tableView, rowAnimation: .Automatic)
			tableView.endUpdates()
		}
	}
	
	func registerReusableViewsWithTableView(tableView: UITableView) {
		tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellID)
	}
	
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return data[section].name
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
