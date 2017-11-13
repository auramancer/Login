struct UsernameLoginDetails {
  let username: String
  let password: String
}

extension LoginHelp {
  static let forgottenUsername = "forgottenUsername"
  static let forgottenPassword = "forgottenPassword"
}

protocol UsernameLoginInteractorInput: LoginInteractorInput {
}

protocol UsernameLoginInteractorOutput: LoginInteractorOutput {
}

protocol UsernameLoginServiceInput: class {
  func logIn(withUsernameDetails: UsernameLoginDetails)
}

protocol UsernameLoginServiceOutput: LoginServiceOutput {
}

class UsernameLoginInteractor: AbstractLoginInteractor, UsernameLoginInteractorInput {
  var service: UsernameLoginServiceInput?
  
  override func invokeService() {
    let usernameDetails = UsernameLoginDetails(username: id ?? "",
                                               password: secret ?? "")
    service?.logIn(withUsernameDetails: usernameDetails)
  }
  
  override func helpWithId() {
    loginInteractorOutput?.showHelp(.forgottenUsername)
  }
  
  override func helpWithSecret() {
    loginInteractorOutput?.showHelp(.forgottenPassword)
  }
}

extension UsernameLoginInteractor: UsernameLoginServiceOutput {
}
