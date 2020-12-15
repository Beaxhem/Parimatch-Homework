import Foundation

func binarySearch<T: Comparable>(arr: [T], key: T) -> Int? {
    var lower = 0
    var higher = arr.count
    
    while lower < higher  {
        let mid = (lower + higher) / 2
        
        if arr[mid] == key {
            return mid
        } else if arr[mid] < key {
            higher = mid - 1
        } else {
            lower = mid
        }
    }
    return nil
}

var arr = [0, 2, 4, 5, 6, 6, 6, 9]

binarySearch(arr: arr, key: 6)
