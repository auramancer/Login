typealias LoginError = String

typealias LoginDestination = String

protocol LoginInteractorInput: class {
  func updateId(_: String)
  func updateSecret(_: String)
  
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
  
  func navigate(to: LoginDestination)
}

protocol LoginServiceOutput: class {
  func didLogIn()
  func didFailToLogIn(dueTo: [LoginError])
}

class AbstractLoginInteractor: LoginInteractorInput {
  weak var output: LoginInteractorOutput?
  
  var id: String?
  var secret: String?
  
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
      output?.loginWasEnabled()
    }
    else {
      output?.loginWasDisabled()
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
  
  func logIn() {
    invokeService()
    
    output?.loginDidBegin()
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
}

extension AbstractLoginInteractor: LoginServiceOutput {
  func didLogIn() {
    output?.loginDidEnd()
  }
  
  func didFailToLogIn(dueTo errors: [LoginError]) {
    output?.loginDidFail(dueTo: errors)
  }
}
