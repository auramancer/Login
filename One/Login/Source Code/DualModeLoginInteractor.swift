import Foundation

enum LoginMode {
  case undetermined
  case username
  case cardNumber
}

protocol DualModeLoginInteractorOutput: UsernameLoginInteractorOutput, CardNumberLoginInteractorOutput {
  func loginModeDidChange(to: LoginMode)
}

protocol DualModeLoginServiceInput: UsernameLoginServiceInput, CardNumberLoginServiceInput {
}

class DualModeLoginInteractor: LoginInteractorInput {
  weak var output: DualModeLoginInteractorOutput? {
    didSet {
      usernameInteractor.loginInteractorOutput = output
      cardNumberInteractor.loginInteractorOutput = output
    }
  }
  
  var service: DualModeLoginServiceInput? {
    didSet {
      usernameInteractor.service = service
      cardNumberInteractor.service = service
    }
  }
  
  var mode = LoginMode.undetermined
  
  private var usernameInteractor = UsernameLoginInteractor()
  private var cardNumberInteractor = CardNumberLoginInteractor()
  
  private var subInteractor: AbstractLoginInteractor {
    switch mode {
    case .undetermined, .username:
      return usernameInteractor
    case .cardNumber:
      return cardNumberInteractor
    }
  }
  
  func updateId(_ id: String) {
    switchMode(to: mode(for: id))
    subInteractor.updateId(id)
  }
  
  func updateSecret(_ secret: String) {
    subInteractor.updateSecret(secret)
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
  
  private func switchMode(to mode: LoginMode) {
    if self.mode != mode {
      self.mode = mode
      subInteractor.loginInteractorOutput = output
      
      output?.loginModeDidChange(to: mode)
    }
  }
  
  func updateShouldRememberDetails(_ shouldRemember: Bool) {
    subInteractor.updateShouldRememberDetails(shouldRemember)
  }
  
  func helpWithId() {
    subInteractor.helpWithId()
  }
  
  func helpWithSecret() {
    subInteractor.helpWithSecret()
  }
  
  func logIn() {
    subInteractor.logIn()
  }
}

extension DualModeLoginInteractor: LoginServiceOutput {
  func didLogIn() {
    output?.loginDidEnd()
  }
  
  func didFailToLogIn(dueTo errors: [LoginError]) {
    output?.loginDidFail(dueTo: errors)
  }
}
