struct RetailIdentity {
  var cardNumber: String
  var pin: String
  var verificationCode: String?
  var authenticationToken: String?
  var membershipNumber: String?
}

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
  func showIdentityCreation(withIdentity: RetailIdentity)
}

protocol RetailLoginServiceInput: class {
  func logIn(withRetailIdentity: RetailIdentity)
}

protocol RetailLoginServiceOutput: class {
  func changeMemebershipNumber(to: String)
  
  func loginDidSucceed(withSession: String, needToCreateDigitalIdentity: Bool)
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
  
  private var identity: RetailIdentity!
  private var shouldRememberIdentity = false
  
  private var rememberedIdentity: RetailIdentity? {
    return storage?.loadIdentity()
  }
  
  private var rememberedToken: String? {
    return storage?.loadToken()
  }
  
  private var canLogin: Bool {
    return identity.isValid 
  }
  
  private var canLoginOldValue = false
  
  private func outputCanLoginDidChange() {
    let newValue = canLogin
    
    if newValue != canLoginOldValue {
      output?.canLoginDidChange(to: newValue)
      canLoginOldValue = newValue
    }
  }
}

extension RetailLoginInteractor: RetailLoginInteractorInput {
  func load() {
    identity = rememberedIdentity ?? RetailIdentity(cardNumber: "", pin: "")
    identity.authenticationToken = rememberedToken
    canLoginOldValue = canLogin
    
    output?.didLoad(identity: identity, canLogin: canLoginOldValue)
  }
  
  func changeIdentifier(to identifier: String) {
    identity.cardNumber = identifier
    
    outputCanLoginDidChange()
  }
  
  func changeCredential(to credential: String) {
    identity.pin = credential
    
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
  
  func loginDidSucceed(withSession session: String, needToCreateDigitalIdentity: Bool) {
    saveIdentity()
    storage?.saveSession(session)
    
    if needToCreateDigitalIdentity {
      output?.showIdentityCreation(withIdentity: identity)
    }
    else {
      output?.loginDidEnd()
    }
  }
  
  private func saveIdentity() {
    if shouldRememberIdentity {
      storage?.saveIdentity(RetailIdentity(cardNumber: identity.cardNumber, pin: ""))
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

extension RetailIdentity {
  init(cardNumber: String, pin: String) {
    self.init(cardNumber: cardNumber,
              pin: pin,
              verificationCode: nil,
              authenticationToken: nil,
              membershipNumber: nil)
  }
  
  init(cardNumber: String, pin: String, authenticationToken: String?) {
    self.init(cardNumber: cardNumber,
              pin: pin,
              verificationCode: nil,
              authenticationToken: authenticationToken,
              membershipNumber: nil)
  }
  
  var isValid: Bool {
    return cardNumberIsValid && pinIsValid
  }
  
  var cardNumberIsValid: Bool {
    return cardNumber != ""
  }
  
  var pinIsValid: Bool {
    return pin != ""
  }
}
