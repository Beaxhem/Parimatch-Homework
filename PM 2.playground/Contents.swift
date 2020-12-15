import Foundation

struct Stack<T> {
    var elements: [T] = []
    
    mutating func push(_ element: T) {
        elements.append(element)
    }
    
    mutating func pop() -> T? {
        return elements.popLast()
    }
}


protocol MyProtocol {
    associatedtype Test
    
    
}


struct Student {
    var score: Int
}

let arr = [
