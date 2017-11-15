struct RetailLoginRequest {
  let cardNumber: String
  let pin: String
  var verificationCode: String?
  var authenticationToken: String?
}

extension LoginHelp {
  static let cardNumber = LoginHelp("cardNumber")
  static let pin = LoginHelp("pin")
}

protocol RetailLoginInteractorInput: class {
  func initialize()
  
  func changeCardNumber(to: String)
  func changePIN(to: String)
  
  func logIn(shouldRememberCardNumber: Bool)
  
  func helpWithCardNumber()
  func helpWithPIN()
}

protocol RetailLoginInteractorOutput: class {
  func cardNumberDidChange(to: String)
  func pinDidChange(to: String)
  func canLoginDidChange(to: Bool)
  
  func loginDidBegin()
  func loginDidEnd()
  func loginDidFail(withErrors: [LoginError])
  
  func showHelp(_: LoginHelp)
  func inquireVerificationCode(forRequest: RetailLoginRequest)
}

protocol RetailLoginServiceInput: class {
  func logIn(withCardNumberRequest: RetailLoginRequest)
}

protocol RetailLoginServiceOutput: class {
  func loginDidSucceed()
  func loginDidFail(dueTo: [LoginError])
  func loginDidFailDueToInvalidToken()
}

protocol RetailLoginStorage: class {
  func saveCardNumber(_: String)
  func loadCardNumber() -> String?
  func saveToken(_: String)
  func loadToken() -> String?
  func removeToken()
}

class RetailLoginInteractor {
  weak var output: RetailLoginInteractorOutput?
  var service: RetailLoginServiceInput?
  var storage: RetailLoginStorage?
  
  private var cardNumber = ""
  private var pin = ""
  private var shouldRememberCardNumber = false
  private var isLoggingIn = false
  
  private var request: RetailLoginRequest {
    return RetailLoginRequest(cardNumber: cardNumber,
                                  pin: pin,
                                  authenticationToken: token)
  }
  
  private var token: String? {
    return storage?.loadToken()
  }
  
  private var canLogin: Bool {
    return cardNumberIsValid && pinIsValid && !isLoggingIn
  }
  
  private var cardNumberIsValid: Bool {
    return cardNumber != ""
  }
  
  private var pinIsValid: Bool {
    return pin != ""
  }
}

extension RetailLoginInteractor: RetailLoginInteractorInput {
  func initialize() {
    cardNumber = storage?.loadCardNumber() ?? ""
    pin = ""
    
    output?.cardNumberDidChange(to: cardNumber)
    output?.pinDidChange(to: pin)
    output?.canLoginDidChange(to: canLogin)
  }
  
  func changeCardNumber(to cardNumber: String) {
    guard self.cardNumber != cardNumber else { return }
    
    self.cardNumber = cardNumber
    
    output?.cardNumberDidChange(to: cardNumber)
    output?.canLoginDidChange(to: canLogin)
  }
  
  func changePIN(to pin: String) {
    guard self.pin != pin else { return }
    
    self.pin = pin
    
    output?.pinDidChange(to: pin)
    output?.canLoginDidChange(to: canLogin)
  }
  
  func logIn(shouldRememberCardNumber shouldRemember: Bool) {
    guard canLogin else { return }
    
    shouldRememberCardNumber = shouldRemember
    isLoggingIn = true
    
    service?.logIn(withCardNumberRequest: request)
    
    output?.canLoginDidChange(to: canLogin)
    output?.loginDidBegin()
  }
  
  func helpWithCardNumber() {
    output?.showHelp(.cardNumber)
  }
  
  func helpWithPIN() {
    output?.showHelp(.pin)
  }
}

extension RetailLoginInteractor: RetailLoginServiceOutput {
  func loginDidSucceed() {
    isLoggingIn = false
    saveCardNumber()
    
    output?.loginDidEnd()
  }
  
  private func saveCardNumber() {
    if shouldRememberCardNumber {
      storage?.saveCardNumber(cardNumber)
    }
  }
  
  func loginDidFail(dueTo errors: [LoginError]) {
    isLoggingIn = false
    
    output?.canLoginDidChange(to: canLogin)
    output?.loginDidFail(withErrors: errors)
  }
  
  func loginDidFailDueToInvalidToken() {
    isLoggingIn = false
    storage?.removeToken()
    
    output?.inquireVerificationCode(forRequest: request)
  }
}

extension RetailLoginRequest {
  init(cardNumber: String, pin: String) {
    self.init(cardNumber: cardNumber,
              pin: pin,
              verificationCode: nil,
              authenticationToken: nil)
  }
  
  init(cardNumber: String, pin: String, authenticationToken: String?) {
    self.init(cardNumber: cardNumber,
              pin: pin,
              verificationCode: nil,
              authenticationToken: authenticationToken)
  }
}

