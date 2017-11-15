protocol LoginVerificationInteractorInput {
  func reset(withRequest: RetailLoginRequest, shouldRememberCardNumber: Bool)
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
  var service: RetailLoginServiceInput?
  var storage: RetailLoginStorage?
  
  private var request: RetailLoginRequest?
  private var shouldRememberCardNumber = false
  private var isVerifying = false
  
  private var canVerify: Bool {
    guard let request = request,
      let code = request.verificationCode else { return false }
    
    return code != "" && !isVerifying
  }
}

extension LoginVerificationInteractor: LoginVerificationInteractorInput {
  func reset(withRequest request: RetailLoginRequest,
             shouldRememberCardNumber: Bool) {
    self.request = request
    self.shouldRememberCardNumber = shouldRememberCardNumber
    
    output?.canVerifyDidChange(to: canVerify)
  }
  
  func changeCode(to code: String) {
    request?.verificationCode = code
    
    output?.canVerifyDidChange(to: canVerify)
  }
  
  func verify() {
    guard canVerify else { return }
    
    isVerifying = true
    
    service?.logIn(withCardNumberRequest: request!)
    
    output?.canVerifyDidChange(to: canVerify)
    output?.verificationDidBegin()
  }
  
  func resendCode() {
    guard let request = request else { return }
    
    service?.logIn(withCardNumberRequest: request)
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
      storage?.saveCardNumber(request!.cardNumber)
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

