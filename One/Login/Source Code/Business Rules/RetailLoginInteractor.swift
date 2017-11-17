struct RetailLoginRequest {
  var cardNumber: String
  var pin: String
  var verificationCode: String?
  var authenticationToken: String?
  var membershipNumber: String?
}

extension LoginHelp {
  static let cardNumber = LoginHelp("cardNumber")
  static let pin = LoginHelp("pin")
}

protocol RetailLoginInteractorInput: class {
  func load()
  
  func changeCardNumber(to: String)
  func changePIN(to: String)
  
  func logIn(shouldRememberCardNumber: Bool)
  
  func helpWithCardNumber()
  func helpWithPIN()
}

protocol RetailLoginInteractorOutput: class {
  func didLoad(cardNumber: String, pin: String, canLogin: Bool)
  
  func canLoginDidChange(to: Bool)
  
  func loginDidBegin()
  func loginDidEnd()
  func loginDidFail(withErrors: [String])
  
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
}

class RetailLoginInteractor {
  weak var output: RetailLoginInteractorOutput?
  var service: RetailLoginServiceInput?
  var storage: RetailLoginStorage?
  
  private var request: RetailLoginRequest!
  private var shouldRememberCardNumber = false
  
  private var rememberedCardNumber: String {
    return storage?.loadCardNumber() ?? ""
  }
  
  private var rememberedPIN: String {
    return ""
  }
  
  private var remeberedToken: String? {
    return storage?.loadToken()
  }
  
  private var canLogin: Bool {
    return request?.isValid ?? false
  }
  
  private var canLoginOldValue = false
  
  private func outputCanLoginDidChange() {
    let newValue = canLogin
    
    if newValue != canLoginOldValue {
      output?.canLoginDidChange(to: newValue)
      canLoginOldValue = newValue
    }
  }
}

extension RetailLoginInteractor: RetailLoginInteractorInput {
  func load() {
    request = RetailLoginRequest(cardNumber: rememberedCardNumber,
                                 pin: rememberedPIN,
                                 authenticationToken: remeberedToken)
    canLoginOldValue = canLogin
    
    output?.didLoad(cardNumber: request.cardNumber,
                    pin: request.pin,
                    canLogin: canLoginOldValue)
  }
  
  func changeCardNumber(to cardNumber: String) {
    request.cardNumber = cardNumber
    
    outputCanLoginDidChange()
  }
  
  func changePIN(to pin: String) {
    request.pin = pin
    
    outputCanLoginDidChange()
  }
  
  func logIn(shouldRememberCardNumber shouldRemember: Bool) {
    shouldRememberCardNumber = shouldRemember
    
    service?.logIn(withCardNumberRequest: request)
    
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
    if shouldRememberCardNumber {
      storage?.saveCardNumber(request.cardNumber)
    }
    
    output?.loginDidEnd()
  }
  
  func loginDidFail(dueTo errors: [LoginError]) {
    let messages = errors.map{ $0.message }
    output?.loginDidFail(withErrors: messages)
  }
  
  func loginDidFailDueToInvalidToken() {
    output?.inquireVerificationCode(forRequest: request)
  }
}

extension RetailLoginRequest {
  init(cardNumber: String, pin: String) {
    self.init(cardNumber: cardNumber,
              pin: pin,
              verificationCode: nil,
              authenticationToken: nil,
              membershipNumber: nil)
  }
  
  init(cardNumber: String, pin: String, authenticationToken: String?) {
    self.init(cardNumber: cardNumber,
              pin: pin,
              verificationCode: nil,
              authenticationToken: authenticationToken,
              membershipNumber: nil)
  }
  
  var isValid: Bool {
    return cardNumberIsValid && pinIsValid
  }
  
  var cardNumberIsValid: Bool {
    return cardNumber != ""
  }
  
  var pinIsValid: Bool {
    return pin != ""
  }
}


