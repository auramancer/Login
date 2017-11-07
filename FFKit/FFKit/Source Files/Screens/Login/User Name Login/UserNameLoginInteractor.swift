struct UserNameLoginDetails {
  let userName: String
  let password: String
}

protocol UserNameLoginInteractorInput: class {
  func updateDetail(_: UserNameLoginDetails)
  func logIn()
}

enum UserNameLoginState {
  case notReady
  case ready
  case inProgress
}

enum UserNameLoginResult {
  case succeeded
  case failed([UserNameLoginError])
}

protocol UserNameLoginInteractorOutput: class {
  func updateState(_: UserNameLoginState)
  func updateResult(_: UserNameLoginResult)
}

protocol UserNameLoginServiceInput: class {
  func logIn(withDetails: UserNameLoginDetails)
}

protocol UserNameLoginServiceOutput: class {
  func didLogIn()
  func didFailToLogIn(dueTo: [UserNameLoginError])
}

enum UserNameLoginError: Error {
  case unrecognized
  case serviceNotAvailable
}

class UserNameLoginInteractor {
  weak var output: UserNameLoginInteractorOutput?
  weak var service: UserNameLoginServiceInput?
  
  var details: UserNameLoginDetails?
}

extension UserNameLoginInteractor: UserNameLoginInteractorInput {
  func updateDetail(_ details: UserNameLoginDetails) {
    self.details = details
  
    output?.updateState(canLogIn ? .ready : .notReady)
  }
  
  private var canLogIn: Bool {
    return userNameIsValid && passwordIsValid
  }
  
  private var userNameIsValid: Bool {
    guard let userName = details?.userName else { return false }
    
    return userName != ""
  }
  
  private var passwordIsValid: Bool {
    guard let password = details?.password else { return false }
    
    return password != ""
  }
  
  func logIn() {
    guard let details = details else { return }
    
    service?.logIn(withDetails: details)
    
    output?.updateState(.inProgress)
  }
}

extension UserNameLoginInteractor: UserNameLoginServiceOutput {
  func didLogIn() {
    output?.updateState(.ready)
    output?.updateResult(.succeeded)
  }
  
  func didFailToLogIn(dueTo errors: [UserNameLoginError]) {
    output?.updateState(.ready)
    output?.updateResult(.failed(errors))
  }
}
