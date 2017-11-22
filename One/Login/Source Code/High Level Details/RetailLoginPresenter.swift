protocol RetailLoginPresenterOutput: class {
  func changeIdentifier(to: String)
  func changeCredential(to: String)
  func changeCanLogin(to: Bool)
  func changeIsLoggingIn(to: Bool)
  
  func showMessage(_: LoginMessage)
  func clearMessage()
  
  func goToHelpPage(for: LoginHelp)
  func goToVerificationPage(withIdentity: RetailIdentity)
  func leave()
}

class RetailLoginPresenter {
  weak var output: RetailLoginPresenterOutput?
}

extension RetailLoginPresenter: RetailLoginInteractorOutput {
  func didLoad(identity: RetailIdentity, canLogin: Bool) {
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
    output?.showMessage(LoginMessage(errors: errors))
  }
  
  func showHelp(_ help: LoginHelp) {
    output?.goToHelpPage(for: help)
  }
  
  func showVerification(withIdentity identity: RetailIdentity) {
    output?.changeIsLoggingIn(to: false)
    output?.goToVerificationPage(withIdentity: identity)
  }
}
