//
//  UIKitIntegration.swift
//  ArrayDiff
//
//  Created by Adlai Holler on 10/3/15.
//  Copyright © 2015 Adlai Holler. All rights reserved.
//

import UIKit

public extension NestedDiff {
	/**
	Apply this diff to the given table view.
	
	This should be called on the main thread between tableView.beginUpdates and tableView.endUpdates
	*/
	public func applyToTableView(tableView: UITableView, rowAnimation: UITableViewRowAnimation) {
		assert(NSThread.isMainThread())
		if sectionsDiff.removedIndexes.count > 0 {
			tableView.deleteSections(sectionsDiff.removedIndexes, withRowAnimation: rowAnimation)
		}
		if sectionsDiff.insertedIndexes.count > 0 {
			tableView.insertSections(sectionsDiff.insertedIndexes, withRowAnimation: rowAnimation)
		}
		for (oldSection, diffOrNil) in itemDiffs.enumerate() {
			if let diff = diffOrNil {
				tableView.deleteRowsAtIndexPaths(diff.removedIndexes.indexPathsInSection(oldSection, ascending: false), withRowAnimation: rowAnimation)
				if let newSection = sectionsDiff.newIndexForOldIndex(oldSection) {
					tableView.insertRowsAtIndexPaths(diff.insertedIndexes.indexPathsInSection(newSection), withRowAnimation: rowAnimation)
				} else {
					assertionFailure("Found an item diff for a section that was removed. Wat.")
				}
			}
		}
	}
	
	/**
	Apply this diff to the given collection view.
	
	This should be called on the main thread inside collectionView.performBatchUpdates
	*/
	public func applyToCollectionView(collectionView: UICollectionView) {
		assert(NSThread.isMainThread())
		if sectionsDiff.removedIndexes.count > 0 {
			collectionView.deleteSections(sectionsDiff.removedIndexes)
		}
		if sectionsDiff.insertedIndexes.count > 0 {
			collectionView.insertSections(sectionsDiff.insertedIndexes)
		}
		for (oldSection, diffOrNil) in itemDiffs.enumerate() {
			if let diff = diffOrNil {
				collectionView.deleteItemsAtIndexPaths(diff.removedIndexes.indexPathsInSection(oldSection))
				if let newSection = sectionsDiff.newIndexForOldIndex(oldSection) {
					collectionView.insertItemsAtIndexPaths(diff.insertedIndexes.indexPathsInSection(newSection))
				} else {
					assertionFailure("Found an item diff for a section that was removed. Wat.")
				}
			}
		}
	}
}
