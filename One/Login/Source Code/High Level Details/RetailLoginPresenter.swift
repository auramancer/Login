protocol RetailLoginPresenterOutput: class {
  func changeCardNumber(to: String)
  func changePIN(to: String)
  func changeCanLogin(to: Bool)
  func changeIsLoggingIn(to: Bool)
  
  func showMessage(_: LoginMessage)
  func clearMessage()
  
  func goToHelpPage(for: LoginHelp)
  func goToVerificationPage(withIdentity: RetailIdentity)
  func goToIdentityCreationPage(withIdentity: RetailIdentity)
  func leave()
}

class RetailLoginPresenter {
  weak var output: RetailLoginPresenterOutput?
}

extension RetailLoginPresenter: RetailLoginInteractorOutput {
  func didLoad(identity: RetailIdentity, canLogin: Bool) {
    output?.changeCardNumber(to: identity.cardNumber)
    output?.changePIN(to: identity.pin)
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
    output?.showMessage(errorMessage(with: errors))
  }
  
  func showHelp(_ help: LoginHelp) {
    output?.goToHelpPage(for: help)
  }
  
  func showVerification(withIdentity identity: RetailIdentity) {
    output?.changeIsLoggingIn(to: false)
    output?.goToVerificationPage(withIdentity: identity)
  }
  
  func showIdentityCreation(withIdentity identity: RetailIdentity) {
    output?.changeIsLoggingIn(to: false)
    output?.goToIdentityCreationPage(withIdentity: identity)
  }
}
