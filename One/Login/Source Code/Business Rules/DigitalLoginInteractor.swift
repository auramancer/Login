struct DigitalIdentity {
  var identifier: String
  var credential: String
}

extension LoginHelp {
  static let username = LoginHelp("username")
  static let password = LoginHelp("password")
}

protocol DigitalLoginInteractorInput: class {
  func load()
  
  func changeIdentifier(to: String)
  func changeCredential(to: String)
  func changeShouldRememberIdentity(to: Bool)
  
  func logIn()
  
  func helpWithIdentifier()
  func helpWithCredential()
}

protocol DigitalLoginInteractorOutput: class {
  func didLoad(identity: DigitalIdentity, canLogin: Bool)
  
  func canLoginDidChange(to: Bool)
  
  func loginDidBegin()
  func loginDidEnd()
  func loginDidFail(withErrors: [String])
  
  func showHelp(_: LoginHelp)
}

protocol DigitalLoginServiceInput: class {
  func logIn(withDigitalIdentity: DigitalIdentity)
}

protocol DigitalLoginServiceOutput: class {
  func loginDidSucceed(withSession: String)
  func loginDidFail(dueTo: [LoginError])
}

protocol DigitalLoginStorage: class {
  func saveIdentity(_: DigitalIdentity)
  func loadIdentity() -> DigitalIdentity?
  func saveSession(_: String)
}

class DigitalLoginInteractor {
  weak var output: DigitalLoginInteractorOutput?
  var service: DigitalLoginServiceInput?
  var storage: DigitalLoginStorage?
  var biometricsInteractor: BiometricsLoginInteractorInput?
  
  private var identity: DigitalIdentity!
  private var shouldRememberIdentity = false
  
  private var rememberedIdentity: DigitalIdentity? {
    return storage?.loadIdentity()
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

extension DigitalLoginInteractor: DigitalLoginInteractorInput {
  func load() {
    identity = rememberedIdentity ?? DigitalIdentity(identifier: "", credential: "")
    canLoginOldValue = canLogin
    
    output?.didLoad(identity: identity, canLogin: canLoginOldValue)
  }
  
  func changeIdentifier(to username: String) {
    identity.identifier = username
    
    outputCanLoginDidChange()
  }
  
  func changeCredential(to password: String) {
    identity.credential = password
    
    outputCanLoginDidChange()
  }
  
  func changeShouldRememberIdentity(to shouldRemember: Bool) {
    shouldRememberIdentity = shouldRemember
  }
  
  func logIn() {
    service?.logIn(withDigitalIdentity: identity)
    
    output?.loginDidBegin()
  }
  
  func helpWithIdentifier() {
    output?.showHelp(.username)
  }
  
  func helpWithCredential() {
    output?.showHelp(.password)
  }
}

extension DigitalLoginInteractor: DigitalLoginServiceOutput {
  func loginDidSucceed(withSession session: String) {
    saveIdentity()
    storage?.saveSession(session)
    
    output?.loginDidEnd()
  }
  
  private func saveIdentity() {
    if shouldRememberIdentity {
      storage?.saveIdentity(DigitalIdentity(identifier: identity.identifier, credential: ""))
    }
  }
  
  func loginDidFail(dueTo errors: [LoginError]) {
    let messages = errors.map{ $0.message }
    output?.loginDidFail(withErrors: messages)
  }
}

extension DigitalIdentity {
  var isValid: Bool {
    return identifierIsValid && credentialIsValid
  }
  
  var identifierIsValid: Bool {
    return identifier != ""
  }
  
  var credentialIsValid: Bool {
    return credential != ""
  }
}
