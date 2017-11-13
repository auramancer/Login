struct CardNumberLoginDetails {
  let cardNumber: String
  let pin: String
  
  let verificationCode: String?
  let authenticationToken: String?
}

extension LoginHelp {
  static let forgottenCardNumber = "forgottenMembershipCardNumber"
  static let forgottenPIN = "forgottenPIN"
}

protocol CardNumberLoginInteractorInput: LoginInteractorInput {
}

protocol CardNumberLoginInteractorOutput: LoginInteractorOutput {
  func inquireAuthenticationCode()
}

protocol CardNumberLoginServiceInput: class {
  func logIn(withCardNumberDetails: CardNumberLoginDetails)
}

protocol CardNumberLoginServiceOutput: LoginServiceOutput {
  func didLogin(withToken: String)
  func didFailToLogInDueToInvalidToken()
}

class CardNumberLoginInteractor: AbstractLoginInteractor, CardNumberLoginInteractorInput {
  var service: CardNumberLoginServiceInput?
  var output: CardNumberLoginInteractorOutput? {
    return loginInteractorOutput as? CardNumberLoginInteractorOutput
  }
  
  override func invokeService() {
    let cardNumberDetails = CardNumberLoginDetails(cardNumber: id ?? "",
                                                   pin: secret ?? "")
    service?.logIn(withCardNumberDetails: cardNumberDetails)
  }
  
  override func helpWithId() {
    loginInteractorOutput?.showHelp(.forgottenCardNumber)
  }
  
  override func helpWithSecret() {
    loginInteractorOutput?.showHelp(.forgottenPIN)
  }
}

extension CardNumberLoginInteractor: CardNumberLoginServiceOutput {
  func didLogin(withToken: String) {
  }
  
  func didFailToLogInDueToInvalidToken() {
    output?.inquireAuthenticationCode()
  }
}

extension CardNumberLoginDetails {
  init(cardNumber: String, pin: String) {
    self.init(cardNumber: cardNumber,
              pin: pin,
              verificationCode: nil,
              authenticationToken: nil)
  }
}
