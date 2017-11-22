protocol LoginVerificationInteractorInput {
  func load(withIdentity: RetailIdentity)
  func changeCode(to: String)
  
  func verify()
  func resendCode(confirmed: Bool)
}

protocol LoginVerificationInteractorOutput: class {
  func didLoad(tokenDidExpire: Bool, canVerify: Bool)
  func canVerifyDidChange(to: Bool)
  
  func verificationDidBegin()
  func verificationDidEnd()
  func verificationDidFail(dueTo: [String])
  
  func showResendConfirmation()
  func showIdentityCreation(withIdentity: RetailIdentity)
}

protocol LoginVerificationServiceOutput: class {
  func loginDidSucceed(withSession: String, token: String, needToCreateDigitalIdentity: Bool)
  func loginDidFail(dueTo: [LoginError])
}

protocol VerificationCodeServiceInput {
  func resendCode(withRetailIdentity: RetailIdentity)
}

class LoginVerificationInteractor {
  weak var output: LoginVerificationInteractorOutput?
  var loginService: RetailLoginServiceInput?
  var codeService: VerificationCodeServiceInput?
  var storage: RetailLoginStorage?
  
  fileprivate var identity: RetailIdentity!
  
  fileprivate var canVerify: Bool {
    return identity.isValidForLoginWithCode
  }
  
  fileprivate var canVerifyOldValue = false
  
  fileprivate func outputCanLoginDidChange() {
    let newValue = canVerify
    
    if newValue != canVerifyOldValue {
      output?.canVerifyDidChange(to: newValue)
      canVerifyOldValue = newValue
    }
  }
}

extension LoginVerificationInteractor: LoginVerificationInteractorInput {
  func load(withIdentity identity: RetailIdentity) {
    self.identity = identity
    self.identity.authenticationToken = nil
    let expired = identity.authenticationToken != nil
    canVerifyOldValue = canVerify
    
    output?.didLoad(tokenDidExpire: expired, canVerify: canVerifyOldValue)
  }
  
  func changeCode(to code: String) {
    identity?.verificationCode = code
    
    outputCanLoginDidChange()
  }
  
  func verify() {
    loginService?.logIn(withRetailIdentity: identity)
    
    output?.verificationDidBegin()
  }
  
  func resendCode(confirmed: Bool) {
    if confirmed {
      codeService?.resendCode(withRetailIdentity: identity)
    }
    else {
      output?.showResendConfirmation()
    }
  }
}

extension LoginVerificationInteractor: LoginVerificationServiceOutput {
  func loginDidSucceed(withSession session: String, token: String, needToCreateDigitalIdentity: Bool) {
    if needToCreateDigitalIdentity {
      createDigitalIdentity(session: session, token: token)
    }
    else {
      endVerification(session: session, token: token)
    }
  }
  
  fileprivate func createDigitalIdentity(session: String, token: String) {
    storage?.saveSession(session)
    identity.authenticationToken = token
    
    output?.showIdentityCreation(withIdentity: identity)
  }
  
  fileprivate func endVerification(session: String, token: String) {
    storage?.saveSession(session)
    storage?.saveToken(token)
    
    output?.verificationDidEnd()
  }
  
  func loginDidFail(dueTo errors: [LoginError]) {
    let messages = errors.map{ $0.message }
    output?.verificationDidFail(dueTo: messages)
  }
}
