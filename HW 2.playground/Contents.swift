import Foundation

class BettingSystem {
    typealias Username = String
    
    private var users: [Username: User] = [:]
    private var bannedUsers: [Username] = []

    private var bets: [Username: [Bet]] = [:]
    
    func register(username: String, password: String, role: Role) throws -> User  {
        guard !isAlreadyRegistered(username: username) else {
            throw LoginError.isAlreadyLoggedIn
        }
        
        var user = User(username: username, password: password, role: role)
        user.dbRef = self
        users[username] = user
        
        return user
    }
    
    func login(username: String, password: String) throws -> User {
        guard isBanned(username: username) else {
            throw LoginError.isBanned
        }
        
        guard let user = users[username] else {
            throw LoginError.isNotRegistered
        }
        
        return user
    }
    
    private func isAlreadyRegistered(username: String) -> Bool {
        if let _ = users[username] {
            return true
        }
        
        return false
    }
    
    
    private func isBanned(username: String) -> Bool {
        return false
    }
    
}

extension BettingSystem {
    func newBet(betString: String, username: String) {
        let b = Bet(betString: betString)
        
        if var usersBets = bets[username] {
            usersBets.append(b)
        } else {
            bets[username] = [b]
        }
    }
    
    func getAllBets(completion: @escaping (Result<[Username: [Bet]], DatabaseError>) -> Void) {
        completion(.success(bets))
    }
    
    func getBets(byUsername username: String, completion: @escaping (Result<[Bet], DatabaseError>) -> Void) {
        guard let bets = bets[username] else {
            completion(.failure(.notFound("Not found")))
            return
        }
        
        completion(.success(bets))
    }
}

struct User {
    var username: String
    var password: String
    var role: Role = .regular
    
    weak var dbRef: BettingSystem?
    
    func placeNewBet(bet: String) {
        guard let dbRef = dbRef else {
            print("dbRef is null")
            return
        }
        
        dbRef.newBet(betString: bet, username: username)
    }
    
    func myBets() {
        dbRef?.getBets(byUsername: username) { res in
            switch res {
            case .failure(let error):
                print("Error: \(error)")
            case .success(let bets):
                print("Your bets:")
                for bet in bets {
                    print("- \(bet)")
                }
            }
        }
    }
}

extension User {
    func getAllBets() {
        guard let dbRef = dbRef else {
            print("dbRef is null")
            return
        }
        
        dbRef.getAllBets { res in
            switch res {
            case .failure(let error):
                print("Error: \(error)")
            case .success(let bets):
                for username in bets.keys {
                    print("\(username)`s bets:")
                    
                    for bet in bets[username]! {
                        print("- \(bet)")
                    }
                }
            }
        }
    }
}

enum Role {
    case admin
    case regular
}


struct Bet: CustomStringConvertible {
    var betString: String
    
    var description: String {
        betString
    }
    
}


enum LoginError: Error {
    case isAlreadyLoggedIn
    case isBanned
    case isNotRegistered
}

enum DatabaseError: Error {
    case notFound(String)
}


let bs = BettingSystem()

let user = try? bs.register(username: "Test", password: "Test", role: .regular)

user?.placeNewBet(bet: "Test bet")

user?.myBets()

let admin = try? bs.register(username: "Admin", password: "Admin", role: .admin)

admin?.getAllBets()

