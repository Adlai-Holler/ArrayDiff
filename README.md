# ArrayDiff

A Swift utility to get the longest-common-subsequence difference of two arrays.

# Usage

A really powerful use for this framework is when updating a UITableView or UICollectionView. It can be very expensive to call `reloadData` but really inconvenient to keep track of array differences your self.

```swift
let old = ["a", "b", "c", "d", "e"]
let new = ["x", "a", "b", "f"]

let diff = old.diff(new)
// diff.insertedIndexes = [0, 3]
// diff.removedIndexes = [2-4]
// diff.commonIndexes = [0-1]

tableView.beginUpdates()
tableView.deleteRowsAtIndexPaths(diff.removedIndexes.indexPathsInSection(0), withRowAnimation: .Automatic)
tableView.insertRowsAtIndexPaths(diff.insertedIndexes.indexPathsInSection(0), withRowAnimation: .Automatic)
tableView.endUpdates()
```
