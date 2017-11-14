extension LoginDestination {
  static let forgottenCardNumber = LoginDestination("forgottenCardNumber")
  static let forgottenPIN = LoginDestination("forgottenPIN")
  static let verificationCode = LoginDestination("verificationCode")
}

protocol CardNumberLoginPresenterOutput: class {
  func showCardNumber(_: String)
  func showPIN(_: String)
  
  func enableLogin()
  func disableLogin()
  
  func showActivityMessage(_: String?)
  func hideActivityMessage()
  func showErrorMessage(_: String)
  func hideErrorMessage()
  
  func goToHelpPage(for: LoginHelp)
  func goToVerificationPage(withDetails: CardNumberLoginDetails)
  func leave()
}

class CardNumberLoginPresenter {
  weak var output: CardNumberLoginPresenterOutput?
}

extension CardNumberLoginPresenter: CardNumberLoginInteractorOutput {
  func cardNumberDidChange(to cardNumber: String) {
    output?.showCardNumber(cardNumber)
  }

  func pinDidChange(to pin: String) {
    output?.showPIN(pin)
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
  
  func inquireVerificationCode(forDetails details: CardNumberLoginDetails) {
    output?.goToVerificationPage(withDetails: details)
  }
}
