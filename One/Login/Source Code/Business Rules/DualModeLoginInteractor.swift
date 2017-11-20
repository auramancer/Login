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
  func showIdentityCreation(withIdentity: RetailIdentity)
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
    usernameInteractor.output = self
    currentInteractor = usernameInteractor
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
  
  private func switchSubInteractor() {
    if shouldUseUsernameInteractor {
      usernameInteractor.output = self
      cardNumberInteractor.output = nil
      currentInteractor = usernameInteractor
    }
    else {
      cardNumberInteractor.output = self
      usernameInteractor.output = nil
      currentInteractor = cardNumberInteractor
    }
  }
  
  private var shouldUseUsernameInteractor: Bool {
    return mode == .undetermined || mode == .digital
  }
  
  private var rememberedIdentifier: String {
    return storage?.loadIdentifier() ?? ""
  }
}

extension DualModeLoginInteractor: DualModeLoginInteractorInput {
  
  func load() {
    switchMode(to: mode(for: rememberedIdentifier))
    
    usernameInteractor.load()
    cardNumberInteractor.load()
  }
  
  func changeIdentifier(to identifier: String) {
    switchMode(to: mode(for: identifier))
    
    usernameInteractor.changeIdentifier(to: identifier)
    cardNumberInteractor.changeIdentifier(to: identifier)
  }
  
  func changeCredential(to credential: String) {
    usernameInteractor.changeCredential(to: credential)
    cardNumberInteractor.changeCredential(to: credential)
  }
  
  func changeShouldRememberIdentity(to shouldRemember: Bool) {
    usernameInteractor.changeShouldRememberIdentity(to: shouldRemember)
    cardNumberInteractor.changeShouldRememberIdentity(to: shouldRemember)
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
    if shouldUseUsernameInteractor {
      output?.didLoad(identifier: identity.identifier,
                      credential: identity.credential,
                      canLogin: canLogin,
                      mode: mode)
    }
  }
  
  func didLoad(identity: RetailIdentity, canLogin: Bool) {
    if !shouldUseUsernameInteractor {
      output?.didLoad(identifier: identity.cardNumber,
                      credential: identity.pin,
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
  
  func showIdentityCreation(withIdentity identity: RetailIdentity) {
    output?.showIdentityCreation(withIdentity: identity)
  }
}

extension DualModeLoginInteractor: DualModeLoginServiceOutput {
  func changeMemebershipNumber(to membershipNumber: String) {
    currentInteractor.changeMemebershipNumber(to: membershipNumber)
  }
  
  func loginDidSucceed(withSession session: String) {
    currentInteractor.loginDidSucceed(withSession: session)
  }
  
  func loginDidSucceed(withSession session: String, token: String) {
    currentInteractor.loginDidSucceed(withSession: session, token: token)
  }
  
  func loginDidFail(dueTo errors: [LoginError]) {
    currentInteractor.loginDidFail(dueTo: errors)
  }
  
  func loginDidFailDueToInvalidToken() {
    currentInteractor.loginDidFailDueToInvalidToken()
  }
}

extension DualModeLoginInteractor: DigitalLoginStorage, RetailLoginStorage {
  func saveIdentity(_ username: String) {
    storage?.saveIdentifier(username)
  }
  
  func loadIdentity() -> String? {
    return shouldUseUsernameInteractor ? storage?.loadIdentifier() : ""
  }
  
  func saveToken(_ token: String) {
    storage?.saveToken(token)
  }
  
  func loadToken() -> String? {
    return storage?.loadToken()
  }
  
  func saveSession(_: String) {
    
  }
}

extension DigitalLoginInteractor: DualModeLoginInteractorInput, DualModeLoginServiceOutput {
}

extension RetailLoginInteractor: DualModeLoginInteractorInput, DualModeLoginServiceOutput {
}

extension DualModeLoginServiceOutput {
  // default
  func changeMemebershipNumber(to: String) {
  }
  
  func loginDidFailDueToInvalidToken() {
  }
}
