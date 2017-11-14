extension LoginDestination {
  static let forgottenUsername = LoginDestination("forgottenUsername")
  static let forgottenPassword = LoginDestination("forgottenPassword")
}

protocol UsernameLoginPresenterOutput: class {
  func showUsername(_: String)
  func showPassword(_: String)
  
  func enableLogin()
  func disableLogin()
  
  func showActivityMessage(_: String?)
  func hideActivityMessage()
  func showErrorMessage(_: String)
  func hideErrorMessage()
  
  func goToHelpPage(for: LoginHelp)
  func leave()
}

class UsernameLoginPresenter {
  weak var output: UsernameLoginPresenterOutput?
}

extension UsernameLoginPresenter: UsernameLoginInteractorOutput {
  func usernameDidChange(to username: String) {
    output?.showUsername(username)
  }

  func passwordDidChange(to password: String) {
    output?.showPassword(password)
  }
  
  func canLoginDidChange(to canLogin: Bool) {
    if canLogin {
      output?.enableLogin()
    }
    else {
      output?.disableLogin()
    }
  }
  
  func loginDidBegin() {
    output?.hideErrorMessage()
    output?.showActivityMessage(activityMessage)
  }
  
  private var activityMessage: String? {
    return nil // No text
  }
  
  func loginDidEnd() {
    output?.hideActivityMessage()
    
    output?.leave()
  }
  
  func loginDidFail(withErrors errors: [LoginError]) {
    output?.hideActivityMessage()
    
    let message = errorMessage(for: errors)
    output?.showErrorMessage(message)
  }
  
  private func errorMessage(for errors: [LoginError]) -> String {
    return errors.first ?? "Something went wrong."
  }
  
  func showHelp(_ help: LoginHelp) {
    output?.goToHelpPage(for: help)
  }
}
