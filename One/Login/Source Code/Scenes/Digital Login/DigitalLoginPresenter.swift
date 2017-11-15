extension LoginDestination {
  static let forgottenUsername = LoginDestination("forgottenUsername")
  static let forgottenPassword = LoginDestination("forgottenPassword")
}

protocol DigitalLoginPresenterOutput: class {
  func changeUsername(to: String)
  func changePassword(to: String)
  func changeCanLogin(to: Bool)
  func changeIsLoggingIn(to: Bool)
  func changeErrorMessage(to: String)
  func clearErrorMessage()
  
  func goToHelpPage(for: LoginHelp)
  func leave()
}

class DigitalLoginPresenter {
  weak var output: DigitalLoginPresenterOutput?
}

extension DigitalLoginPresenter: DigitalLoginInteractorOutput {
  func usernameDidChange(to username: String) {
    output?.changeUsername(to: username)
  }

  func passwordDidChange(to password: String) {
    output?.changePassword(to: password)
  }
  
  func canLoginDidChange(to canLogin: Bool) {
    output?.changeCanLogin(to: canLogin)
  }
  
  func loginDidBegin() {
    output?.clearErrorMessage()
    output?.changeIsLoggingIn(to: true)
  }
  
  func loginDidEnd() {
    output?.changeIsLoggingIn(to: false)
    output?.leave()
  }
  
  func loginDidFail(withErrors errors: [LoginError]) {
    output?.changeIsLoggingIn(to: false)
    output?.changeErrorMessage(to: errorMessage(for: errors))
  }
  
  private func errorMessage(for errors: [LoginError]) -> String {
    return errors.first ?? "Something went wrong."
  }
  
  func showHelp(_ help: LoginHelp) {
    output?.goToHelpPage(for: help)
  }
}
