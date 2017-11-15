struct DigitalLoginRequest {
  let username: String
  let password: String
}

extension LoginHelp {
  static let username = LoginHelp("username")
  static let password = LoginHelp("password")
}

protocol DigitalLoginInteractorInput: class {
  func initialize()
  
  func changeUsername(to: String)
  func changePassword(to: String)
  
  func logIn(shouldRememberUsername: Bool)
  
  func helpWithUsername()
  func helpWithPassword()
}

protocol DigitalLoginInteractorOutput: class {
  func usernameDidChange(to: String)
  func passwordDidChange(to: String)
  func canLoginDidChange(to: Bool)
  
  func loginDidBegin()
  func loginDidEnd()
  func loginDidFail(withErrors: [LoginError])
  
  func showHelp(_: LoginHelp)
}

protocol DigitalLoginServiceInput: class {
  func logIn(withUsernameRequest: DigitalLoginRequest)
}

protocol DigitalLoginServiceOutput: class {
  func loginDidSucceed()
  func loginDidFail(dueTo: [LoginError])
}

protocol DigitalLoginStorage: class {
  func saveUsername(_: String)
  func loadUsername() -> String?
}

class DigitalLoginInteractor {
  weak var output: DigitalLoginInteractorOutput?
  var service: DigitalLoginServiceInput?
  var storage: DigitalLoginStorage?
  
  private var username = ""
  private var password = ""
  private var shouldRememberUsername = false
  private var isLoggingIn = false
  
  private var request: DigitalLoginRequest {
    return DigitalLoginRequest(username: username, password: password)
  }
  
  private var canLogin: Bool {
    return usernameIsValid && passwordIsValid && !isLoggingIn
  }
  
  private var usernameIsValid: Bool {
    return username != ""
  }
  
  private var passwordIsValid: Bool {
    return password != ""
  }
}

extension DigitalLoginInteractor: DigitalLoginInteractorInput {
  func initialize() {
    username = storage?.loadUsername() ?? ""
    password = ""
    
    output?.usernameDidChange(to: username)
    output?.passwordDidChange(to: password)
    output?.canLoginDidChange(to: canLogin)
  }
  
  func changeUsername(to username: String) {
    guard self.username != username else { return }
    
    self.username = username
    
    output?.usernameDidChange(to: username)
    output?.canLoginDidChange(to: canLogin)
  }
  
  func changePassword(to password: String) {
    guard self.password != password else { return }
    
    self.password = password
    
    output?.passwordDidChange(to: password)
    output?.canLoginDidChange(to: canLogin)
  }
  
  func logIn(shouldRememberUsername shouldRemember: Bool) {
    guard canLogin else { return }
    
    shouldRememberUsername = shouldRemember
    isLoggingIn = true
    
    service?.logIn(withUsernameRequest: request)
    
    output?.canLoginDidChange(to: canLogin)
    output?.loginDidBegin()
  }
  
  func helpWithUsername() {
    output?.showHelp(.username)
  }
  
  func helpWithPassword() {
    output?.showHelp(.password)
  }
}

extension DigitalLoginInteractor: DigitalLoginServiceOutput {
  func loginDidSucceed() {
    isLoggingIn = false
    
    if shouldRememberUsername {
      storage?.saveUsername(username)
    }
    
    output?.loginDidEnd()
  }
  
  func loginDidFail(dueTo errors: [LoginError]) {
    isLoggingIn = false
    
    output?.canLoginDidChange(to: canLogin)
    output?.loginDidFail(withErrors: errors)
  }
}
