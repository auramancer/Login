struct UsernameLoginDetails {
  let username: String
  let password: String
}

protocol UsernameLoginServiceInput: class {
  func logIn(withUsernameDetails: UsernameLoginDetails)
}

extension LoginDestination {
  static let forgottenUsername = "forgottenUsername"
  static let forgottenPassword = "forgottenPassword"
}

class UsernameLoginInteractor: AbstractLoginInteractor {
  var service: UsernameLoginServiceInput?
  
  override func invokeService() {
    let usernameDetails = UsernameLoginDetails(username: id ?? "",
                                               password: secret ?? "")
    service?.logIn(withUsernameDetails: usernameDetails)
  }
  
  override func helpWithId() {
    output?.navigate(to: .forgottenUsername)
  }
  
  override func helpWithSecret() {
    output?.navigate(to: .forgottenPassword)
  }
}
