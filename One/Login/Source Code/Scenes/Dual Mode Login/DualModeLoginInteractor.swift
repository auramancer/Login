import Foundation

enum LoginMode {
  case undetermined
  case username
  case cardNumber
}

protocol DualModeLoginInteractorInput: class {
  func reset()
  
  func changeID(to: String)
  func changeSecret(to: String)
  
  func logIn(shouldRememberID: Bool)
  
  func helpWithID()
  func helpWithSecret()
}

protocol DualModeLoginInteractorOutput: class {
  func idDidChange(to: String)
  func secretDidChange(to: String)
  func canLoginDidChange(to: Bool)
  
  func loginModeDidChange(to: LoginMode)
  
  func loginDidBegin()
  func loginDidEnd()
  func loginDidFail(withErrors: [LoginError])
  
  func showHelp(_: LoginHelp)
  func inquireVerificationCode(forDetails: CardNumberLoginDetails)
}

protocol DualModeLoginServiceInput: UsernameLoginServiceInput, CardNumberLoginServiceInput {
}

protocol DualModeLoginServiceOutput: UsernameLoginServiceOutput, CardNumberLoginServiceOutput {
}

protocol DualModeLoginStorage: UsernameLoginStorage, CardNumberLoginStorage {
}

class DualModeLoginInteractor {
  weak var output: DualModeLoginInteractorOutput?
  
  var service: DualModeLoginServiceInput? {
    didSet {
      usernameInteractor.service = service
      cardNumberInteractor.service = service
    }
  }
  
  var storage: DualModeLoginStorage? {
    didSet {
      usernameInteractor.storage = storage
      cardNumberInteractor.storage = storage
    }
  }
  
  var usernameInteractor = UsernameLoginInteractor()
  var cardNumberInteractor = CardNumberLoginInteractor()
  
  private var mode = LoginMode.undetermined
  
  init() {
    connectToSubInteractor()
  }
}

extension DualModeLoginInteractor: DualModeLoginInteractorInput {
  func reset() {
    mode = LoginMode.undetermined
    connectToSubInteractor()
    
    usernameInteractor.reset()
    cardNumberInteractor.reset()
    
    output?.loginModeDidChange(to: mode)
  }
  
  func changeID(to id: String) {
    switchMode(to: mode(for: id))
    
    usernameInteractor.changeUsername(to: id)
    cardNumberInteractor.changeCardNumber(to: id)
  }
  
  func changeSecret(to secret: String) {
    usernameInteractor.changePassword(to: secret)
    cardNumberInteractor.changePIN(to: secret)
  }
  
  private func switchMode(to mode: LoginMode) {
    guard self.mode != mode else { return }
    
    self.mode = mode
    connectToSubInteractor()
    
    output?.loginModeDidChange(to: mode)
  }
  
  private func mode(for id: String) -> LoginMode {
    if isMembershipCardNumber(id) {
      return .cardNumber
    }
    else if isPartialMembershipCardNumber(id) {
      return .undetermined
    }
    return .username
  }
  
  private func isMembershipCardNumber(_ id: String) -> Bool {
    // starts with 6 digits
    return pattern("^[0-9]{6,}?", doesMatch: id)
  }
  
  private func isPartialMembershipCardNumber(_ id: String) -> Bool {
    // 0-5 digits
    return pattern("^[0-9]{0,5}?$", doesMatch: id)
  }
  
  private func pattern(_ pattern: String, doesMatch string: String) -> Bool {
    let expression = try! NSRegularExpression(pattern: pattern, options: [])
    let range = NSRange(string.startIndex..<string.endIndex, in: string)
    return expression.matches(in: string, options: [], range: range).count > 0
  }
  
  private func connectToSubInteractor() {
    switch mode {
    case .undetermined, .username:
      usernameInteractor.output = self
      cardNumberInteractor.output = nil
    case .cardNumber:
      usernameInteractor.output = nil
      cardNumberInteractor.output = self
    }
  }
  
  func logIn(shouldRememberID: Bool) {
    switch mode {
    case .undetermined, .username:
      usernameInteractor.logIn(shouldRememberUsername: shouldRememberID)
    case .cardNumber:
      cardNumberInteractor.logIn(shouldRememberCardNumber: shouldRememberID)
    }
  }
  
  func helpWithID() {
    switch mode {
    case .undetermined, .username:
      usernameInteractor.helpWithUsername()
    case .cardNumber:
      cardNumberInteractor.helpWithCardNumber()
    }
  }
  
  func helpWithSecret() {
    switch mode {
    case .undetermined, .username:
      usernameInteractor.helpWithPassword()
    case .cardNumber:
      cardNumberInteractor.helpWithPIN()
    }
  }
}

extension DualModeLoginInteractor: UsernameLoginInteractorOutput, CardNumberLoginInteractorOutput {
  func usernameDidChange(to username: String) {
    output?.idDidChange(to: username)
  }
  
  func passwordDidChange(to password: String) {
    output?.secretDidChange(to: password)
  }
  
  func cardNumberDidChange(to cardNumber: String) {
    output?.idDidChange(to: cardNumber)
  }
  
  func pinDidChange(to pin: String) {
    output?.secretDidChange(to: pin)
  }
  
  func canLoginDidChange(to canLogin: Bool) {
    output?.canLoginDidChange(to: canLogin)
  }
  
  func loginDidBegin() {
    output?.loginDidBegin()
  }
  
  func loginDidEnd() {
    output?.loginDidEnd()
  }
  
  func loginDidFail(withErrors errors: [LoginError]) {
    output?.loginDidFail(withErrors: errors)
  }
  
  func showHelp(_ help: LoginHelp) {
    output?.showHelp(help)
  }
  
  func inquireVerificationCode(forDetails details: CardNumberLoginDetails) {
    output?.inquireVerificationCode(forDetails: details)
  }
}

extension DualModeLoginInteractor: DualModeLoginServiceOutput {
  func loginDidSucceed() {
    switch mode {
    case .undetermined, .username:
      usernameInteractor.loginDidSucceed()
    case .cardNumber:
      cardNumberInteractor.loginDidSucceed()
    }
  }
  
  func loginDidFail(dueTo errors: [LoginError]) {
    switch mode {
    case .undetermined, .username:
      usernameInteractor.loginDidFail(dueTo: errors)
    case .cardNumber:
      cardNumberInteractor.loginDidFail(dueTo: errors)
    }
  }
  
  func loginDidFailDueToExpiredToken() {
    cardNumberInteractor.loginDidFailDueToExpiredToken()
  }
}
