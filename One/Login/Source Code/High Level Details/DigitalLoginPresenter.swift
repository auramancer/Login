extension LoginDestination {
  static let forgottenUsername = LoginDestination("forgottenUsername")
  static let forgottenPassword = LoginDestination("forgottenPassword")
}

protocol DigitalLoginPresenterOutput: class {
  func changeUsername(to: String)
  func changePassword(to: String)
  func changeCanLogin(to: Bool)
  func changeIsLoggingIn(to: Bool)
  
  func showMessage(_: LoginMessage)
  func clearMessage()
  
  func goToHelpPage(for: LoginHelp)
  func leave()
}

class DigitalLoginPresenter {
  weak var output: DigitalLoginPresenterOutput?
}

extension DigitalLoginPresenter: DigitalLoginInteractorOutput {
  func didLoad(username: String, password: String, canLogin: Bool) {
    output?.changeUsername(to: username)
    output?.changePassword(to: password)
    output?.changeCanLogin(to: canLogin)
  }
  
  func canLoginDidChange(to canLogin: Bool) {
    output?.changeCanLogin(to: canLogin)
  }
  
  func loginDidBegin() {
    output?.clearMessage()
    output?.changeIsLoggingIn(to: true)
  }
  
  func loginDidEnd() {
    output?.changeIsLoggingIn(to: false)
    output?.leave()
  }
  
  func loginDidFail(withErrors errors: [String]) {
    output?.changeIsLoggingIn(to: false)
    output?.showMessage(LoginMessage(text: errors.joined(separator: "\n\n"), style: .error))
  }
  
  func showHelp(_ help: LoginHelp) {
    output?.goToHelpPage(for: help)
  }
}
