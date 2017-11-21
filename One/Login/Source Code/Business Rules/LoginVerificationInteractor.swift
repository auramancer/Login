protocol LoginVerificationError {
  var message: String { get }
}

protocol LoginVerificationInteractorInput {
  func load(withIdentity: RetailIdentity)
  func changeCode(to: String)
  
  func verify()
  func resendCode(confirmed: Bool)
}

protocol LoginVerificationInteractorOutput: class {
  func didLoad(canVerify: Bool)
  func canVerifyDidChange(to: Bool)
  
  func verificationDidBegin()
  func verificationDidEnd()
  func verificationDidFail(dueTo: [String])
  
  func showResendConfirmation()
  func showIdentityCreation(withIdentity: RetailIdentity)
}

protocol LoginVerificationServiceOutput: class {
  func loginDidSucceed(withSession: String, token: String, needToCreateDigitalIdentity: Bool)
  func loginDidFail(dueTo: [LoginVerificationError])
}

protocol VerificationCodeServiceInput {
  func resendCode(withRetailIdentity: RetailIdentity)
}

class LoginVerificationInteractor {
  weak var output: LoginVerificationInteractorOutput?
  var loginService: RetailLoginServiceInput?
  var codeService: VerificationCodeServiceInput?
  var storage: RetailLoginStorage?
  
  private var identity: RetailIdentity!
  
  private var canVerify: Bool {
    return identity.isValidForLoginWithCode
  }
  
  private var canVerifyOldValue = false
  
  private func outputCanLoginDidChange() {
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
    canVerifyOldValue = canVerify
    
    output?.didLoad(canVerify: canVerifyOldValue)
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
  
  private func createDigitalIdentity(session: String, token: String) {
    storage?.saveSession(session)
    identity.authenticationToken = token
    
    output?.showIdentityCreation(withIdentity: identity)
  }
  
  private func endVerification(session: String, token: String) {
    storage?.saveSession(session)
    storage?.saveToken(token)
    
    output?.verificationDidEnd()
  }
  
  func loginDidFail(dueTo errors: [LoginVerificationError]) {
    let messages = errors.map{ $0.message }
    output?.verificationDidFail(dueTo: messages)
  }
}
