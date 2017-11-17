extension LoginDestination {
  static let forgottenCardNumber = LoginDestination("forgottenCardNumber")
  static let forgottenPIN = LoginDestination("forgottenPIN")
  static let verificationCode = LoginDestination("verificationCode")
}

protocol RetailLoginPresenterOutput: class {
  func changeCardNumber(to: String)
  func changePIN(to: String)
  func changeCanLogin(to: Bool)
  func changeIsLoggingIn(to: Bool)
  
  func showMessage(_: LoginMessage)
  func clearMessage()
  
  func goToHelpPage(for: LoginHelp)
  func goToVerificationPage(withRequest: RetailLoginRequest)
  func leave()
}

class RetailLoginPresenter {
  weak var output: RetailLoginPresenterOutput?
}

extension RetailLoginPresenter: RetailLoginInteractorOutput {
  func didLoad(cardNumber: String, pin: String, canLogin: Bool) {
    output?.changeCardNumber(to: cardNumber)
    output?.changePIN(to: pin)
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
  
  func inquireVerificationCode(forRequest request: RetailLoginRequest) {
    output?.goToVerificationPage(withRequest: request)
  }
}
