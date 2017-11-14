protocol LoginVerificationInteractorInput {
  func reset(withDetails: CardNumberLoginDetails, shouldRememberCardNumber: Bool)
  func changeCode(to: String)
  
  func verify()
  func resendCode()
}

protocol LoginVerificationInteractorOutput: class {
  func canVerifyDidChange(to: Bool)
  
  func verificationDidBegin()
  func verificationDidEnd()
  func verificationDidFail(dueTo: [LoginError])
}

protocol  LoginVerificationServiceOutput: class {
  func loginDidSucceed(withToken: String)
  func loginDidFail(dueTo: [LoginError])
}

class LoginVerificationInteractor {
  weak var output: LoginVerificationInteractorOutput?
  var service: CardNumberLoginServiceInput?
  var storage: CardNumberLoginStorage?
  
  private var details: CardNumberLoginDetails?
  private var shouldRememberCardNumber = false
  private var isVerifying = false
  
  private var canVerify: Bool {
    guard let details = details,
      let code = details.verificationCode else { return false }
    
    return code != "" && !isVerifying
  }
}

extension LoginVerificationInteractor: LoginVerificationInteractorInput {
  func reset(withDetails details: CardNumberLoginDetails,
             shouldRememberCardNumber: Bool) {
    self.details = details
    self.shouldRememberCardNumber = shouldRememberCardNumber
    
    output?.canVerifyDidChange(to: canVerify)
  }
  
  func changeCode(to code: String) {
    details?.verificationCode = code
    
    output?.canVerifyDidChange(to: canVerify)
  }
  
  func verify() {
    guard canVerify else { return }
    
    isVerifying = true
    
    service?.logIn(withCardNumberDetails: details!)
    
    output?.canVerifyDidChange(to: canVerify)
    output?.verificationDidBegin()
  }
  
  func resendCode() {
    guard let details = details else { return }
    
    service?.logIn(withCardNumberDetails: details)
  }
}

extension LoginVerificationInteractor: LoginVerificationServiceOutput {
  func loginDidSucceed(withToken token: String) {
    isVerifying = false
    saveCardNumber()
    saveToken(token)
    
    output?.verificationDidEnd()
  }
  
  private func saveCardNumber() {
    if shouldRememberCardNumber {
      storage?.saveCardNumber(details!.cardNumber)
    }
  }
  
  private func saveToken(_ token: String) {
    storage?.saveToken(token)
  }
  
  func loginDidFail(dueTo errors: [LoginError]) {
    isVerifying = false
    
    output?.canVerifyDidChange(to: canVerify)
    output?.verificationDidFail(dueTo: errors)
  }
}

