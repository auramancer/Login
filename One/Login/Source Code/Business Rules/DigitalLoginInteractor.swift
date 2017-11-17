struct DigitalLoginRequest {
  var username: String
  var password: String
}

extension LoginHelp {
  static let username = LoginHelp("username")
  static let password = LoginHelp("password")
}

protocol DigitalLoginInteractorInput: class {
  func load()
  
  func changeUsername(to: String)
  func changePassword(to: String)
  
  func logIn(shouldRememberUsername: Bool)
  
  func helpWithUsername()
  func helpWithPassword()
}

protocol DigitalLoginInteractorOutput: class {
  func didLoad(username: String, password: String, canLogin: Bool)
  
  func canLoginDidChange(to: Bool)
  
  func loginDidBegin()
  func loginDidEnd()
  func loginDidFail(withErrors: [String])
  
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
  
  private var request: DigitalLoginRequest!
  private var shouldRememberUsername = false
  
  private var rememberedUsername: String {
    return storage?.loadUsername() ?? ""
  }
  
  private var rememberedPassword: String {
    return ""
  }
  
  private var canLogin: Bool {
    return request?.isValid ?? false
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
    request = DigitalLoginRequest(username: rememberedUsername, password: rememberedPassword)
    canLoginOldValue = canLogin
    
    output?.didLoad(username: request.username,
                    password: request.password,
                    canLogin: canLoginOldValue)
  }
  
  func changeUsername(to username: String) {
    request.username = username
    
    outputCanLoginDidChange()
  }
  
  func changePassword(to password: String) {
    request.password = password
    
    outputCanLoginDidChange()
  }
  
  func logIn(shouldRememberUsername shouldRemember: Bool) {
    shouldRememberUsername = shouldRemember
    
    service?.logIn(withUsernameRequest: request)
    
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
    if shouldRememberUsername {
      storage?.saveUsername(request.username)
    }
    
    output?.loginDidEnd()
  }
  
  func loginDidFail(dueTo errors: [LoginError]) {
    let messages = errors.map{ $0.message }
    output?.loginDidFail(withErrors: messages)
  }
}

extension DigitalLoginRequest {
  var isValid: Bool {
    return usernameIsValid && passwordIsValid
  }
  
  var usernameIsValid: Bool {
    return username != ""
  }
  
  var passwordIsValid: Bool {
    return password != ""
  }
}
