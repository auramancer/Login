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
  func changeErrorMessage(to: String)
  func clearErrorMessage()
  
  func goToHelpPage(for: LoginHelp)
  func goToVerificationPage(withRequest: RetailLoginRequest)
  func leave()
}

class RetailLoginPresenter {
  weak var output: RetailLoginPresenterOutput?
}

extension RetailLoginPresenter: RetailLoginInteractorOutput {
  func cardNumberDidChange(to cardNumber: String) {
    output?.changeCardNumber(to: cardNumber)
  }

  func pinDidChange(to pin: String) {
    output?.changePIN(to: pin)
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
  
  func inquireVerificationCode(forRequest request: RetailLoginRequest) {
    output?.goToVerificationPage(withRequest: request)
  }
}
