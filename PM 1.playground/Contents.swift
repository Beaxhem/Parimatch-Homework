import Foundation

func factorialRecursive(n: Int) -> Int {
    return n == 1 ? 1 : n * factorialRecursive(n: n-1)
}

factorialRecursive(n: 4)


func factorialIterative(n: Int) -> Int {
    var factorial = 1
    var i = n

    while i != 0 {
        factorial *= i
        i -= 1
    }
    
    return factorial
}

factorialIterative(n: 4)


//func fib(n: Int) -> Int {
//    if n == 1 || n == 2 {
//        return 1
//    }
//
//    return fib(n: n-1) + fib(n: n-2)
//}
//
//fib(n: 3)

func fib(n: Int) -> [Int] {
    var res: [Int] = [0, 1]
    
    for i in 1...n-2 {
        res.append(res[i-1]+res[i])
    }
    
    return res
}

fib(n: 10)


func piFraction(n: Int) -> Int {    
    let piString = String(Double.pi)
    
    let startIndex = piString.index(piString.startIndex, offsetBy: n)
    let endIndex = piString.index(piString.startIndex, offsetBy: n)
    
    return Int(piString[startIndex...endIndex])!
    
}

piFraction(n: 16)
