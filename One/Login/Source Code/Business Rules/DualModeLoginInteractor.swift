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
  func changeShouldRememberIdentity(to: Bool)
  
  func logIn()
  
  func helpWithIdentifier()
  func helpWithCredential()
}

protocol DualModeLoginInteractorOutput: class {
  func didLoad(identifier: String, credential: String, canLogin: Bool, mode: LoginMode)
  
  func canLoginDidChange(to: Bool)
  func loginModeDidChange(to: LoginMode)
  
  func loginDidBegin()
  func loginDidEnd()
  func loginDidFail(withErrors: [String])
  
  func showHelp(_: LoginHelp)
  func showVerification(withIdentity: RetailIdentity)
}

protocol DualModeLoginServiceInput: DigitalLoginServiceInput, RetailLoginServiceInput {
}

protocol DualModeLoginServiceOutput: DigitalLoginServiceOutput, RetailLoginServiceOutput {
}

protocol DualModeLoginStorage  {
  func saveIdentity(_: Identity)
  func loadIdentity() -> Identity?
  func saveToken(_: String)
  func loadToken() -> String?
  func saveSession(_: String)
}

class DualModeLoginInteractor {
  weak var output: DualModeLoginInteractorOutput?
  
  var service: DualModeLoginServiceInput? {
    didSet {
      digitalInteractor.service = service
      retailInteractor.service = service
    }
  }
  
  var storage: DualModeLoginStorage?
  
  fileprivate var mode = LoginMode.undetermined
  
  fileprivate var digitalInteractor = DigitalLoginInteractor()
  fileprivate var retailInteractor = RetailLoginInteractor()
  fileprivate var currentInteractor: (DualModeLoginInteractorInput & DualModeLoginServiceOutput)!
  fileprivate var currentServiceOutput: DualModeLoginServiceOutput!
  
  init() {
    digitalInteractor.output = self
    digitalInteractor.storage = self
    currentInteractor = digitalInteractor
    
    retailInteractor.storage = self
  }
  
  fileprivate func switchMode(to mode: LoginMode) {
    guard self.mode != mode else { return }
    
    self.mode = mode
    switchSubInteractor()
    
    output?.loginModeDidChange(to: mode)
  }
  
  fileprivate func mode(for id: String) -> LoginMode {
    if isMembershipCardNumber(id) {
      return .retail
    }
    else if isPartialMembershipCardNumber(id) {
      return .undetermined
    }
    return .digital
  }
  
  fileprivate func isMembershipCardNumber(_ id: String) -> Bool {
    // starts with 6 digits
    return id.containsMatch(of: "^[0-9]{6,}?")
  }
  
  fileprivate func isPartialMembershipCardNumber(_ id: String) -> Bool {
    // 0-5 digits
    return id.containsMatch(of: "^[0-9]{0,5}?$")
  }
  
  fileprivate func switchSubInteractor() {
    if shouldUseDigitalInteractor {
      digitalInteractor.output = self
      retailInteractor.output = nil
      currentInteractor = digitalInteractor
    }
    else {
      retailInteractor.output = self
      digitalInteractor.output = nil
      currentInteractor = retailInteractor
    }
  }
  
  fileprivate var shouldUseDigitalInteractor: Bool {
    return mode == .undetermined || mode == .digital
  }
  
  fileprivate var rememberedIdentifier: String {
    return storage?.loadIdentity()?.identifier ?? ""
  }
}

extension DualModeLoginInteractor: DualModeLoginInteractorInput {
  func load() {
    switchMode(to: mode(for: rememberedIdentifier))
    
    digitalInteractor.load()
    retailInteractor.load()
  }
  
  func changeIdentifier(to identifier: String) {
    switchMode(to: mode(for: identifier))
    
    digitalInteractor.changeIdentifier(to: identifier)
    retailInteractor.changeIdentifier(to: identifier)
  }
  
  func changeCredential(to credential: String) {
    digitalInteractor.changeCredential(to: credential)
    retailInteractor.changeCredential(to: credential)
  }
  
  func changeShouldRememberIdentity(to shouldRemember: Bool) {
    digitalInteractor.changeShouldRememberIdentity(to: shouldRemember)
    retailInteractor.changeShouldRememberIdentity(to: shouldRemember)
  }
  
  func logIn() {
    currentServiceOutput = currentInteractor
    
    currentInteractor.logIn()
  }
  
  func helpWithIdentifier() {
    currentInteractor.helpWithIdentifier()
  }
  
  func helpWithCredential() {
    currentInteractor.helpWithCredential()
  }
}

extension DualModeLoginInteractor: DigitalLoginInteractorOutput, RetailLoginInteractorOutput {
  func didLoad(identity: DigitalIdentity, canLogin: Bool) {
    if shouldUseDigitalInteractor {
      output?.didLoad(identifier: identity.identifier,
                      credential: identity.credential,
                      canLogin: canLogin,
                      mode: mode)
    }
  }
  
  func didLoad(identity: RetailIdentity, canLogin: Bool) {
    if !shouldUseDigitalInteractor {
      output?.didLoad(identifier: identity.identifier,
                      credential: identity.credential,
                      canLogin: canLogin,
                      mode: mode)
    }
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
  
  func showVerification(withIdentity identity: RetailIdentity) {
    output?.showVerification(withIdentity: identity)
  }
}

extension DualModeLoginInteractor: DualModeLoginServiceOutput {
  func changeMemebershipNumber(to membershipNumber: String) {
    currentInteractor.changeMemebershipNumber(to: membershipNumber)
  }
  
  func loginDidSucceed(withSession session: String) {
    currentInteractor.loginDidSucceed(withSession: session)
  }
  
  func loginDidFail(dueTo errors: [LoginError]) {
    currentInteractor.loginDidFail(dueTo: errors)
  }
  
  func loginDidFailDueToInvalidToken() {
    currentInteractor.loginDidFailDueToInvalidToken()
  }
}

extension DualModeLoginInteractor: DigitalLoginStorage, RetailLoginStorage {
  func saveIdentity(_ identity: DigitalIdentity) {
    if shouldUseDigitalInteractor {
      storage?.saveIdentity(identity)
    }
  }
  
  func loadIdentity() -> DigitalIdentity? {
    return shouldUseDigitalInteractor ? storage?.loadIdentity() as? DigitalIdentity : nil
  }
  
  func saveIdentity(_ identity: RetailIdentity) {
    if !shouldUseDigitalInteractor {
      storage?.saveIdentity(identity)
    }
  }
  
  func loadIdentity() -> RetailIdentity? {
    return !shouldUseDigitalInteractor ? storage?.loadIdentity() as? RetailIdentity : nil
  }
  
  func saveToken(_ token: String) {
    storage?.saveToken(token)
  }
  
  func loadToken() -> String? {
    return storage?.loadToken()
  }
  
  func saveSession(_ session: String) {
    storage?.saveSession(session)
  }
}

extension DigitalLoginInteractor: DualModeLoginInteractorInput, DualModeLoginServiceOutput {
  func changeMemebershipNumber(to: String) {
  }
  
  func loginDidFailDueToInvalidToken() {
  }
}

extension RetailLoginInteractor: DualModeLoginInteractorInput, DualModeLoginServiceOutput {
}
