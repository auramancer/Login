protocol UserNameLoginPresenterOutput: class {
  func showUserName(_: String)
  func showPassword(_: String)
  func showLogInIsEnabled(_: Bool)
  func showActivityMessage(_: String)
  func showErrorMessage(_: String)
}

class UserNameLoginPresenter {
  weak var output: UserNameLoginPresenterOutput?
}

extension UserNameLoginPresenter: UserNameLoginInteractorOutput {
  func showUserName(_ userName: String) {
    output?.showUserName(userName)
  }
  
  func showPassword(_ password: String) {
    output?.showPassword(password)
  }
  
  func showCanLogIn(_ canLogIn: Bool) {
    output?.showLogInIsEnabled(canLogIn)
  }
  
  func showIsLoggingIn(_: Bool) {
    output?.showActivityMessage("")
  }
  
  func showDidLogIn() {
    
  }
  
  func showDidFailToLogIn(dueTo errors: [Error]) {
    output?.showErrorMessage("")
  }
}
