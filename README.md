# ArrayDiff [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) ![Pods](https://cocoapod-badges.herokuapp.com/v/ArrayDiff/badge.png) ![Pod platforms](https://cocoapod-badges.herokuapp.com/p/ArrayDiff/badge.png)

An efficient Swift utility to compute the difference between two arrays. Get the `removedIndexes` and `insertedIndexes` and pass them directly along to `UITableView` or `UICollectionView` when you update your data! The [diffing algorithm](https://en.wikipedia.org/wiki/Longest_common_subsequence_problem) is the same that powers the `diff` utility – it's robust and quick.

## Usage

A really powerful use for this framework is when updating a UITableView or UICollectionView. It can be very expensive to call `reloadData` but really inconvenient to keep track of array differences your self.

```swift
let old = [
  BasicSection(name: "Alpha", items: ["a", "b", "c", "d", "e"]),
  BasicSection(name: "Bravo", items: ["f", "g", "h", "i", "j"]),
  BasicSection(name: "Charlie", items: ["k", "l", "m", "n", "o"])
]
let new = [
  BasicSection(name: "Alpha", items: ["a", "b", "d", "e", "x"]),
  BasicSection(name: "Charlie", items: ["f", "g", "h", "i", "j"]),
  BasicSection(name: "Delta", items: ["f", "g", "h", "i", "j"])
]

let nestedDiff = old.diffNested(new)
// nestedDiff.sectionsDiff.removedIndexes == [1]
// nestedDiff.sectionsDiff.insertedIndexes == [2]
// nestedDiff.itemDiffs[0].removedIndexes == [2]
// nestedDiff.itemDiffs[0].insertedIndexes == [5]
// etc.

tableView.beginUpdates()
self.data = new
nestedDiff.applyToTableView(tableView, rowAnimation: .Automatic)
tableView.endUpdates()
```

## Limitations

Item moves are treated as remove/insert, so when they are animated the cell will "teleport" to its new position, rather than sliding there. If you would like this feature, let me know in the Issues!

## Example Project

Check out the iOS app in the Example folder to see this framework pushed to its limits to drive a UITableView. In it we have a table view with 20 sections of strings. When you tap update, the data is randomly updated and we assert that the changes we made are equal to the changes that the framework recovers by comparing the two arrays.

## Attribution

Thanks to https://github.com/khanlou/NSArray-LongestCommonSubsequence which I ~~took inspiration~~ totally copied from.
