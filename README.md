# ArrayDiff [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) ![Pods](https://cocoapod-badges.herokuapp.com/v/ArrayDiff/badge.png) ![Pod platforms](https://cocoapod-badges.herokuapp.com/p/ArrayDiff/badge.png) ![Pod license](https://cocoapod-badges.herokuapp.com/l/ArrayDiff/badge.png)

A Swift utility to get the [longest-common-subsequence](https://en.wikipedia.org/wiki/Longest_common_subsequence_problem) difference of two arrays.

## Usage

A really powerful use for this framework is when updating a UITableView or UICollectionView. It can be very expensive to call `reloadData` but really inconvenient to keep track of array differences your self.

```swift
let old = ["a", "b", "c", "d", "e"]
let new = ["x", "a", "b", "f"]

let diff = old.diff(new)
// diff.commonIndexes = [0-1]
// diff.removedIndexes = [2-4]
// diff.insertedIndexes = [0, 3]

let newIndexForA = diff.newIndexForOldIndex(0) // == 1
let oldIndexForF = diff.oldIndexForNewIndex(3) // == nil

tableView.beginUpdates()
tableView.deleteRowsAtIndexPaths(diff.removedIndexes.indexPathsInSection(0), withRowAnimation: .Automatic)
tableView.insertRowsAtIndexPaths(diff.insertedIndexes.indexPathsInSection(0), withRowAnimation: .Automatic)
tableView.endUpdates()
```

## Example Project

Check out the iOS app in the Example folder to see this framework pushed to its limits to drive a UITableView. In it we have a table view with 20 sections of strings. When you tap update, the data is randomly updated and we assert that the changes we made are equal to the changes that the framework recovers by comparing the two arrays.

## Attribution

Thanks to https://github.com/khanlou/NSArray-LongestCommonSubsequence which I ~~took inspiration~~ totally copied from.
