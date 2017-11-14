struct UsernameLoginDetails {
  let username: String
  let password: String
}

extension LoginHelp {
  static let username = LoginHelp("username")
  static let password = LoginHelp("password")
}

protocol UsernameLoginInteractorInput: class {
  func reset()
  
  func changeUsername(to: String)
  func changePassword(to: String)
  
  func logIn(shouldRememberUsername: Bool)
  
  func helpWithUsername()
  func helpWithPassword()
}

protocol UsernameLoginInteractorOutput: class {
  func usernameDidChange(to: String)
  func passwordDidChange(to: String)
  func canLoginDidChange(to: Bool)
  
  func loginDidBegin()
  func loginDidEnd()
  func loginDidFail(withErrors: [LoginError])
  
  func showHelp(_: LoginHelp)
}

protocol UsernameLoginServiceInput: class {
  func logIn(withUsernameDetails: UsernameLoginDetails)
}

protocol UsernameLoginServiceOutput: class {
  func loginDidSucceed()
  func loginDidFail(dueTo: [LoginError])
}

protocol UsernameLoginStorage: class {
  func saveUsername(_: String)
  func loadUsername() -> String?
}

class UsernameLoginInteractor {
  weak var output: UsernameLoginInteractorOutput?
  var service: UsernameLoginServiceInput?
  var storage: UsernameLoginStorage?
  
  private var username = ""
  private var password = ""
  private var shouldRememberUsername = false
  private var isLoggingIn = false
  
  private var details: UsernameLoginDetails {
    return UsernameLoginDetails(username: username, password: password)
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

extension UsernameLoginInteractor: UsernameLoginInteractorInput {
  func reset() {
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
    
    service?.logIn(withUsernameDetails: details)
    
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

extension UsernameLoginInteractor: UsernameLoginServiceOutput {
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
