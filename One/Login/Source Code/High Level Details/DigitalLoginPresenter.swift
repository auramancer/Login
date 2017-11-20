protocol DigitalLoginPresenterOutput: class {
  func changeIdentifier(to: String)
  func changeCredential(to: String)
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
  func didLoad(identity: DigitalIdentity, canLogin: Bool) {
    output?.changeIdentifier(to: identity.identifier)
    output?.changeCredential(to: identity.credential)
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
