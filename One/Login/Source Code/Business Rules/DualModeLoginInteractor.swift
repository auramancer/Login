import Foundation

enum LoginMode {
  case undetermined
  case digital
  case retail
}

protocol DualModeLoginInteractorInput: class {
  func load()
  
  func changeIdentifier(to: String)
  func changeCredential(to: String)
  
  func logIn(shouldRememberIdentifier: Bool)
  
  func helpWithIdentifier()
  func helpWithCredential()
}

protocol DualModeLoginInteractorOutput: class {
  func didLoad(withIdentifier: String, credential: String, canLogin: Bool, mode: LoginMode)
  
  func canLoginDidChange(to: Bool)
  func loginModeDidChange(to: LoginMode)
  
  func loginDidBegin()
  func loginDidEnd()
  func loginDidFail(withErrors: [String])
  
  func showHelp(_: LoginHelp)
  func inquireVerificationCode(forRequest: RetailLoginRequest)
}

protocol DualModeLoginServiceInput: DigitalLoginServiceInput, RetailLoginServiceInput {
}

protocol DualModeLoginServiceOutput: DigitalLoginServiceOutput, RetailLoginServiceOutput {
}

protocol DualModeLoginStorage: DigitalLoginStorage, RetailLoginStorage {
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
  
  private var mode = LoginMode.undetermined
  
  private var usernameInteractor = DigitalLoginInteractor()
  private var cardNumberInteractor = RetailLoginInteractor()
  private var currentInteractor: (DualModeLoginInteractorInput & DualModeLoginServiceOutput)!
  private var currentServiceOutput: DualModeLoginServiceOutput!
  
  init() {
    switchSubInteractor()
  }
  
  private func switchSubInteractor() {
    switch mode {
    case .undetermined, .digital:
      usernameInteractor.output = self
      cardNumberInteractor.output = nil
      currentInteractor = usernameInteractor
    case .retail:
      cardNumberInteractor.output = self
      usernameInteractor.output = nil
      currentInteractor = cardNumberInteractor
    }
  }
  
  private func switchMode(to mode: LoginMode) {
    guard self.mode != mode else { return }
    
    self.mode = mode
    switchSubInteractor()
    
    output?.loginModeDidChange(to: mode)
  }
  
  private func mode(for id: String) -> LoginMode {
    if isMembershipCardNumber(id) {
      return .retail
    }
    else if isPartialMembershipCardNumber(id) {
      return .undetermined
    }
    return .digital
  }
  
  private func isMembershipCardNumber(_ id: String) -> Bool {
    // starts with 6 digits
    return id.containsMatch(of: "^[0-9]{6,}?")
  }
  
  private func isPartialMembershipCardNumber(_ id: String) -> Bool {
    // 0-5 digits
    return id.containsMatch(of: "^[0-9]{0,5}?$")
  }
}

extension DualModeLoginInteractor: DualModeLoginInteractorInput {
  func load() {
    
    
    usernameInteractor.load()
    cardNumberInteractor.load()
  }
  
  func changeIdentifier(to id: String) {
    switchMode(to: mode(for: id))
    
    usernameInteractor.changeUsername(to: id)
    cardNumberInteractor.changeCardNumber(to: id)
  }
  
  func changeCredential(to credential: String) {
    usernameInteractor.changePassword(to: credential)
    cardNumberInteractor.changePIN(to: credential)
  }
  
  func logIn(shouldRememberIdentifier: Bool) {
    currentServiceOutput = currentInteractor
    
    currentInteractor.logIn(shouldRememberIdentifier: shouldRememberIdentifier)
  }
  
  func helpWithIdentifier() {
    currentInteractor.helpWithIdentifier()
  }
  
  func helpWithCredential() {
    currentInteractor.helpWithCredential()
  }
}

extension DualModeLoginInteractor: DigitalLoginInteractorOutput, RetailLoginInteractorOutput {
  func didLoad(username: String, password: String, canLogin: Bool) {
  }
  
  func didLoad(cardNumber: String, pin: String, canLogin: Bool) {
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
  
  func loginDidFail(withErrors errors: [String]) {
    output?.loginDidFail(withErrors: errors)
  }
  
  func showHelp(_ help: LoginHelp) {
    output?.showHelp(help)
  }
  
  func inquireVerificationCode(forRequest request: RetailLoginRequest) {
    output?.inquireVerificationCode(forRequest: request)
  }
}

extension DualModeLoginInteractor: DualModeLoginServiceOutput {
  func loginDidSucceed() {
    currentInteractor.loginDidSucceed()
  }
  
  func loginDidFail(dueTo errors: [LoginError]) {
    currentInteractor.loginDidFail(dueTo: errors)
  }
  
  func loginDidFailDueToInvalidToken() {
    currentInteractor.loginDidFailDueToInvalidToken()
  }
}

extension DigitalLoginInteractor: DualModeLoginInteractorInput, DualModeLoginServiceOutput {
  func changeIdentifier(to id: String) {
    changeUsername(to: id)
  }
  
  func changeCredential(to credential: String) {
    changePassword(to: credential)
  }
  
  func logIn(shouldRememberIdentifier should: Bool) {
    logIn(shouldRememberUsername: should)
  }
  
  func helpWithIdentifier() {
    helpWithUsername()
  }
  
  func helpWithCredential() {
    helpWithPassword()
  }
}

extension RetailLoginInteractor: DualModeLoginInteractorInput, DualModeLoginServiceOutput {
  func changeIdentifier(to id: String) {
    changeCardNumber(to: id)
  }
  
  func changeCredential(to credential: String) {
    changePIN(to: credential)
  }
  
  func logIn(shouldRememberIdentifier should: Bool) {
    logIn(shouldRememberCardNumber: should)
  }
  
  func helpWithIdentifier() {
    helpWithCardNumber()
  }
  
  func helpWithCredential() {
    helpWithPIN()
  }
}

extension DualModeLoginServiceOutput {
  func loginDidFailDueToInvalidToken() {
  }
}
