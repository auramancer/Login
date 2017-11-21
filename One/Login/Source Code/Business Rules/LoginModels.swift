import Foundation

protocol Identity {
  var identifier: String { get }
  var credential: String { get }
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

protocol LoginError {
  var message: String { get }
}

struct LoginMessage {
  var text: String
  var style: Style
  
  enum Style {
    case `default`
    case error
  }
}

func errorMessage(with errors: [String]) -> LoginMessage {
  return LoginMessage(text: errors.joined(separator: "\n\n"), style: .error)
}

extension String {
  func containsMatch(of pattern: String) -> Bool {
    let expression = try! NSRegularExpression(pattern: pattern, options: [])
    return expression.matches(in: self, options: [], range: range).count > 0
  }
  
  var range: NSRange {
    return NSRange(startIndex..<endIndex, in: self)
  }
}

struct SimpleError {
  var message: String
  
  init(_ message: String) {
    self.message = message
  }
}

