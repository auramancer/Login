extension LoginHelp {
  static let cardNumber = LoginHelp("cardNumber")
  static let pin = LoginHelp("pin")
}

protocol RetailLoginInteractorInput: class {
  func load()
  
  func changeIdentifier(to: String)
  func changeCredential(to: String)
  func changeShouldRememberIdentity(to: Bool)
  
  func logIn()
  
  func helpWithIdentifier()
  func helpWithCredential()
}

protocol RetailLoginInteractorOutput: class {
  func didLoad(identity: RetailIdentity, canLogin: Bool)
  
  func canLoginDidChange(to: Bool)
  
  func loginDidBegin()
  func loginDidEnd()
  func loginDidFail(withErrors: [String])
  
  func showHelp(_: LoginHelp)
  func showVerification(withIdentity: RetailIdentity)
}

protocol RetailLoginServiceInput: class {
  func logIn(withRetailIdentity: RetailIdentity)
}

protocol RetailLoginServiceOutput: class {
  func changeMemebershipNumber(to: String)
  
  func loginDidSucceed(withSession: String)
  func loginDidFail(dueTo: [LoginError])
  func loginDidFailDueToInvalidToken()
}

protocol RetailLoginStorage: class {
  func saveIdentity(_: RetailIdentity)
  func loadIdentity() -> RetailIdentity?
  func saveToken(_: String)
  func loadToken() -> String?
  func saveSession(_: String)
}

class RetailLoginInteractor {
  weak var output: RetailLoginInteractorOutput?
  var service: RetailLoginServiceInput?
  var storage: RetailLoginStorage?
  
  fileprivate var identity: RetailIdentity!
  fileprivate var shouldRememberIdentity = false
  
  fileprivate var rememberedIdentity: RetailIdentity? {
    return storage?.loadIdentity()
  }
  
  fileprivate var rememberedToken: String? {
    return storage?.loadToken()
  }
  
  fileprivate var canLogin: Bool {
    return identity.isValid 
  }
  
  fileprivate var canLoginOldValue = false
  
  fileprivate func outputCanLoginDidChange() {
    let newValue = canLogin
    
    if newValue != canLoginOldValue {
      output?.canLoginDidChange(to: newValue)
      canLoginOldValue = newValue
    }
  }
}

extension RetailLoginInteractor: RetailLoginInteractorInput {
  func load() {
    identity = rememberedIdentity ?? RetailIdentity(identifier: "", credential: "")
    identity.authenticationToken = rememberedToken
    canLoginOldValue = canLogin
    
    output?.didLoad(identity: identity, canLogin: canLoginOldValue)
  }
  
  func changeIdentifier(to identifier: String) {
    identity.identifier = identifier
    
    outputCanLoginDidChange()
  }
  
  func changeCredential(to credential: String) {
    identity.credential = credential
    
    outputCanLoginDidChange()
  }
  
  func changeShouldRememberIdentity(to shouldRemember: Bool) {
    shouldRememberIdentity = shouldRemember
  }
  
  func logIn() {
    service?.logIn(withRetailIdentity: identity)
    
    output?.loginDidBegin()
  }
  
  func helpWithIdentifier() {
    output?.showHelp(.cardNumber)
  }
  
  func helpWithCredential() {
    output?.showHelp(.pin)
  }
}

extension RetailLoginInteractor: RetailLoginServiceOutput {
  func changeMemebershipNumber(to membershipNumber: String) {
    identity.membershipNumber = membershipNumber
  }
  
  func loginDidSucceed(withSession session: String) {
    saveIdentity()
    storage?.saveSession(session)
    
    output?.loginDidEnd()
  }
  
  fileprivate func saveIdentity() {
    if shouldRememberIdentity {
      storage?.saveIdentity(RetailIdentity(identifier: identity.identifier, credential: ""))
    }
  }
  
  func loginDidFail(dueTo errors: [LoginError]) {
    let messages = errors.map{ $0.message }
    output?.loginDidFail(withErrors: messages)
  }
  
  func loginDidFailDueToInvalidToken() {
    saveIdentity()
    
    output?.showVerification(withIdentity: identity)
  }
}
