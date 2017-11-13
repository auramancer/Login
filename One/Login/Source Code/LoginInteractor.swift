typealias LoginError = String

typealias LoginHelp = String

protocol LoginInteractorInput: class {
  func updateId(_: String)
  func updateSecret(_: String)
  func updateShouldRememberDetails(_: Bool)
  
  func logIn()
  
  func helpWithId()
  func helpWithSecret()
}

protocol LoginInteractorOutput: class {
  func loginWasEnabled()
  func loginWasDisabled()
  
  func loginDidBegin()
  func loginDidEnd()
  func loginDidFail(dueTo: [LoginError])
  
  func showHelp(_: LoginHelp)
}

protocol LoginServiceOutput: class {
  func didLogIn()
  func didFailToLogIn(dueTo: [LoginError])
}

class AbstractLoginInteractor: LoginInteractorInput, LoginServiceOutput {
  weak var loginInteractorOutput: LoginInteractorOutput?
  
  var id: String?
  var secret: String?
  var shouldRememberDetails = false
  
  func updateId(_ id: String) {
    guard self.id != id else { return }
  
    self.id = id
    enableOrDisableLogin()
  }
  
  func updateSecret(_ secret: String) {
    guard self.secret != secret else { return }
    
    self.secret = secret
    enableOrDisableLogin()
  }
  
  private func enableOrDisableLogin() {
    if detailsAreValid {
      loginInteractorOutput?.loginWasEnabled()
    }
    else {
      loginInteractorOutput?.loginWasDisabled()
    }
  }
  
  private var detailsAreValid: Bool {
    return id != nil && secret != nil && validateId(id!) && validateSecret(secret!)
  }
  
  func validateId(_ id: String) -> Bool {
    return id != ""
  }
  
  func validateSecret(_ secret: String) -> Bool {
    return secret != ""
  }
  
  func updateShouldRememberDetails(_ shouldRemember: Bool) {
    shouldRememberDetails = shouldRemember
  }
  
  func logIn() {
    invokeService()
    
    loginInteractorOutput?.loginDidBegin()
  }
  
  func invokeService() {
    // abstract
  }
  
  func helpWithId() {
    // abstract
  }
  
  func helpWithSecret() {
    // abstract
  }
  
  func didLogIn() {
    if shouldRememberDetails {
      rememberDetails()
    }
    
    loginInteractorOutput?.loginDidEnd()
  }
  
  func rememberDetails() {
    // abstract
  }
  
  func didFailToLogIn(dueTo errors: [LoginError]) {
    loginInteractorOutput?.loginDidFail(dueTo: errors)
  }
}
