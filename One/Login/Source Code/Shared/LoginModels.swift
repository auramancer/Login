struct LoginDestination: Equatable {
  let rawValue: String
  
  init(_ rawValue: String) {
    self.rawValue = rawValue
  }
  
  static func ==(lhs: LoginDestination, rhs: LoginDestination) -> Bool {
    return lhs.rawValue == rhs.rawValue
  }
}

struct LoginHelp: Equatable {
  let rawValue: String
  
  init(_ rawValue: String) {
    self.rawValue = rawValue
  }
  
  static func ==(lhs: LoginHelp, rhs: LoginHelp) -> Bool {
    return lhs.rawValue == rhs.rawValue
  }
}

typealias LoginError = String
