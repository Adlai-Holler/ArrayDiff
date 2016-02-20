//
//  UIKitIntegration.swift
//  ArrayDiff
//
//  Created by Adlai Holler on 10/3/15.
//  Copyright © 2015 Adlai Holler. All rights reserved.
//

import UIKit

public extension ArrayDiff {
	/**
	Apply this diff to items in the given section of the collection view.

	This should be called on the main thread inside collectionView.performBatchUpdates
	*/
	public func applyToItemsInCollectionView(collectionView: UICollectionView, section: Int) {
		assert(NSThread.isMainThread())
		// Apply updates in safe order for good measure.
		// Deletes, descending
		// Inserts, ascending
		collectionView.deleteItemsAtIndexPaths(removedIndexes.indexPathsInSection(section, ascending: false))
		collectionView.insertItemsAtIndexPaths(insertedIndexes.indexPathsInSection(section))
	}

	/**
	Apply this diff to rows in the given section of the table view.

	This should be called on the main thread between tableView.beginUpdates and tableView.endUpdates
	*/
	public func applyToRowsInTableView(tableView: UITableView, section: Int, rowAnimation: UITableViewRowAnimation) {
		assert(NSThread.isMainThread())
		// Apply updates in safe order for good measure.
		// Deletes, descending
		// Inserts, ascending
		tableView.deleteRowsAtIndexPaths(removedIndexes.indexPathsInSection(section, ascending: false), withRowAnimation: rowAnimation)
		tableView.insertRowsAtIndexPaths(insertedIndexes.indexPathsInSection(section), withRowAnimation: rowAnimation)
	}

	/**
	Apply this diff to the sections of the table view.

	This should be called on the main thread between tableView.beginUpdates and tableView.endUpdates
	*/
	public func applyToSectionsInTableView(tableView: UITableView, rowAnimation: UITableViewRowAnimation) {
		assert(NSThread.isMainThread())
		// Apply updates in safe order for good measure.
		// Deletes, descending
		// Inserts, ascending
		if removedIndexes.count > 0 {
			tableView.deleteSections(removedIndexes, withRowAnimation: rowAnimation)
		}
		if insertedIndexes.count > 0 {
			tableView.insertSections(insertedIndexes, withRowAnimation: rowAnimation)
		}
	}

	/**
	Apply this diff to the sections of the collection view.

	This should be called on the main thread inside collectionView.performBatchUpdates
	*/
	public func applyToSectionsInCollectionView(collectionView: UICollectionView) {
		assert(NSThread.isMainThread())
		// Apply updates in safe order for good measure.
		// Deletes, descending
		// Inserts, ascending
		if removedIndexes.count > 0 {
			collectionView.deleteSections(removedIndexes)
		}
		if insertedIndexes.count > 0 {
			collectionView.insertSections(insertedIndexes)
		}
	}
}

public extension NestedDiff {
	/**
	Apply this nested diff to the given table view.
	
	This should be called on the main thread between tableView.beginUpdates and tableView.endUpdates
	*/
	public func applyToTableView(tableView: UITableView, rowAnimation: UITableViewRowAnimation) {
		assert(NSThread.isMainThread())
		// Apply updates in safe order for good measure.
		// Item deletes, descending
		// Section deletes
		// Section inserts
		// Item inserts, ascending
		for (oldSection, diffOrNil) in itemDiffs.enumerate() {
			if let diff = diffOrNil {
				tableView.deleteRowsAtIndexPaths(diff.removedIndexes.indexPathsInSection(oldSection, ascending: false), withRowAnimation: rowAnimation)
			}
		}
		sectionsDiff.applyToSectionsInTableView(tableView, rowAnimation: rowAnimation)
		for (oldSection, diffOrNil) in itemDiffs.enumerate() {
			if let diff = diffOrNil {
				if let newSection = sectionsDiff.newIndexForOldIndex(oldSection) {
					tableView.insertRowsAtIndexPaths(diff.insertedIndexes.indexPathsInSection(newSection), withRowAnimation: rowAnimation)
				} else {
					assertionFailure("Found an item diff for a section that was removed. Wat.")
				}
			}
		}
	}
	
	/**
	Apply this nested diff to the given collection view.
	
	This should be called on the main thread inside collectionView.performBatchUpdates
	*/
	public func applyToCollectionView(collectionView: UICollectionView) {
		assert(NSThread.isMainThread())
		// Apply updates in safe order for good measure. 
		// Item deletes, descending
		// Section deletes
		// Section inserts
		// Item inserts, ascending
		for (oldSection, diffOrNil) in itemDiffs.enumerate() {
			if let diff = diffOrNil {
				collectionView.deleteItemsAtIndexPaths(diff.removedIndexes.indexPathsInSection(oldSection, ascending: false))
			}
		}
		sectionsDiff.applyToSectionsInCollectionView(collectionView)
		for (oldSection, diffOrNil) in itemDiffs.enumerate() {
			if let diff = diffOrNil {
				if let newSection = sectionsDiff.newIndexForOldIndex(oldSection) {
					collectionView.insertItemsAtIndexPaths(diff.insertedIndexes.indexPathsInSection(newSection))
				} else {
					assertionFailure("Found an item diff for a section that was removed. Wat.")
				}
			}
		}
	}
}
