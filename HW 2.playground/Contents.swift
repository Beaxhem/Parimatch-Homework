import Foundation

class BettingSystem {
    typealias Username = String
    
    private var users: [Username: User] = [:]
    private var bannedUsers: [Username] = []
    private var loggedInUsers: [Username] = []
    
    private var bets: [Username: [Bet]] = [:]
    
    // Betting
    
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


extension BettingSystem {
    // Authorization
    
    func register(username: String, password: String, role: Role) throws -> User  {
        guard !isRegistered(username: username) else {
            print("The username is already taken")
            throw LoginError.alreadyRegistered
        }
        
        var user = User(username: username, password: password, role: role)
        user.dbRef = self
        users[username] = user
        
        loggedInUsers.append(username)
        
        return user
    }
    
    func login(username: String, password: String) throws -> User {
        guard let user = users[username] else {
            print("Couldn't find the user with this username or password")
            throw LoginError.notRegistered
        }
        
        guard isBanned(username: username) else {
            print("You have been banned")
            throw LoginError.banned
        }
        
        guard password == user.password else {
            print("Wrong password. Please try again")
            throw LoginError.wrongPassword
        }
        
        loggedInUsers.append(username)
        
        return user
    }
    
    private func isRegistered(username: String) -> Bool {
        if let _ = users[username] {
            return true
        }
        
        return false
    }
    
    
    private func isBanned(username: String) -> Bool {
        return false
    }
    
    func isLoggedIn(username: String) -> Bool {
        return loggedInUsers.contains(username)
    }
    
    func isPermissionGranted(username: String) throws -> Bool {
        guard isRegistered(username: username) else {
            print("Couldn't find a user with this username")
            throw LoginError.notRegistered
        }
        
        guard !isBanned(username: username) else {
            print("You have been banned")
            throw LoginError.banned
        }
        
        guard isLoggedIn(username: username) else {
            print("You are not logged in")
            throw LoginError.notLoggedin
        }
        
        return true
    }
}

extension BettingSystem {
    func banUser(username: String) throws {
        guard !isBanned(username: username) else {
            throw BanError.alreadyBanned
        }
        
        bannedUsers.append(username)
    }
    
    func unbanUser(username: String) throws {
        guard isBanned(username: username) else {
            throw BanError.notBanned
        }
        
        bannedUsers.removeAll(where: { $0 == username })
    }
}


struct User {
    var username: String
    fileprivate var password: String
    private var role: Role
    
    var isAdmin: Bool {
        self.role == .admin
    }
    
    weak var dbRef: BettingSystem?
    
    init(username: String, password: String, role: Role = .regular) {
        self.username = username
        self.password = password
        self.role = role
    }
}

// Betting
extension User {
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

// Admin functionality
extension User {
    func getAllBets() {
        guard let dbRef = dbRef else {
            print("dbRef is null")
            return
        }
        
        guard isAdmin else {
            print("Permission denied")
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
    
    func banUser(username: String) {
        guard let dbRef = dbRef else {
            print("dbRef is null")
            return
        }
        
        guard isAdmin else {
            print("Permission denied")
            return
        }
        
        do {
            try dbRef.banUser(username: username)
        } catch BanError.alreadyBanned {
            print("The user is already banned")
        } catch {
            print("Error happend: \(error)")
        }
    }
    
    func unbanUser(username: String) {
        guard let dbRef = dbRef else {
            print("dbRef is null")
            return
        }
        
        guard isAdmin else {
            print("Permission denied")
            return
        }
        
        do {
            try dbRef.unbanUser(username: username)
        } catch BanError.alreadyBanned {
            print("The user is already banned")
        } catch {
            print("Error happend: \(error)")
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
    case alreadyLoggedIn
    case alreadyRegistered
    case banned
    case notRegistered
    case notLoggedin
    case wrongPassword
}

enum DatabaseError: Error {
    case notFound(String)
}

enum BanError: Error {
    case alreadyBanned
    case notBanned
}
