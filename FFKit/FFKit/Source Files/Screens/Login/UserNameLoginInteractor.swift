protocol UserNameLoginInteractorInput: class {
  func refresh()
  func attempToChangeUserName(to: String)
  func attempToChangePassword(to: String)
  func logIn()
}

protocol UserNameLoginInteractorOutput: class {
  func showUserName(_: String)
  func showPassword(_: String)
  func showCanLogIn(_: Bool)
  func showIsLoggingIn(_: Bool)
  func showDidLogIn()
  func showDidFailToLogIn(dueTo: [Error])
}

protocol UserNameLoginServiceInput: class {
  func logIn(withUserName: String, password: String)
}

protocol UserNameLoginServiceOutput: class {
  func didLogIn()
  func didFailToLogIn(dueTo: [Error])
}

class UserNameLoginInteractor {
  weak var output: UserNameLoginInteractorOutput?
  weak var service: UserNameLoginServiceInput?
  
  var userName: String = ""
  var password: String = ""
}

extension UserNameLoginInteractor: UserNameLoginInteractorInput {
  func refresh() {
    output?.showUserName(userName)
    output?.showPassword(password)
    output?.showCanLogIn(canLogIn)
  }
  
  func attempToChangeUserName(to userName: String) {
    if canChangeUserName(to: userName) {
      changeUserName(to: userName)
    }
  }
  
  func attempToChangePassword(to password: String) {
    if canChangePassword(to: password) {
      changePassword(to: password)
    }
  }
  
  private func canChangeUserName(to userName: String) -> Bool {
    return self.userName != userName
  }
  
  private func canChangePassword(to password: String) -> Bool {
    return self.password != password
  }
  
  private func changeUserName(to userName: String) {
    self.userName = userName
    
    output?.showUserName(userName)
    output?.showCanLogIn(canLogIn)
  }
  
  private func changePassword(to password: String) {
    self.password = password
    
    output?.showPassword(password)
    output?.showCanLogIn(canLogIn)
  }
  
  private var canLogIn: Bool {
    return userNameIsValid && passwordIsValid
  }
  
  private var userNameIsValid: Bool {
    return userName != ""
  }
  
  private var passwordIsValid: Bool {
    return password != ""
  }
  
  func logIn() {
    guard canLogIn else { return }
    
    service?.logIn(withUserName: userName, password: password)
    output?.showIsLoggingIn(true)
  }
}

extension UserNameLoginInteractor: UserNameLoginServiceOutput {
  func didLogIn() {
    output?.showIsLoggingIn(false)
    output?.showDidLogIn()
  }
  
  func didFailToLogIn(dueTo errors: [Error]) {
    output?.showIsLoggingIn(false)
    output?.showDidFailToLogIn(dueTo: errors)
  }
}
