struct ResendCodeConfirmaiton {
  let message: String
  let confirmActionText: String
  let cancelActionText: String
}

protocol LoginVerificationPresenterOutput: class {
  func changeCanVerify(to: Bool)
  func changeIsVerifying(to: Bool)
  
  func showMessage(_: LoginMessage)
  func clearMessage()
  
  func showResendCodeConfirmaiton(_: ResendCodeConfirmaiton)
  func goToIdentityCreationPage(withIdentity: RetailIdentity)
  func leave()
}

class LoginVerificationPresenter {
  weak var output: LoginVerificationPresenterOutput?
  
  struct Wording {
    static let notFoundMessage = "As this is the first time you have logged in with your membership number, we need to validate your account. We have sent you an SMS and eMail with a new verification code, please enter it below. The code will expire after 30 minutes, after which time you will need to request a new code."
    static let tokenExpiredMessage = "Login successful, it has been 1 month since we last verified your account. We have sent you an SMS and eMail with a new verification code, please enter it below."
  }
}

extension LoginVerificationPresenter: LoginVerificationInteractorOutput {
  func didLoad(tokenDidExpire: Bool, canVerify: Bool) {
    let message = tokenDidExpire ? Wording.tokenExpiredMessage : Wording.notFoundMessage
    
    output?.showMessage(LoginMessage(text: message, style: .default))
    output?.changeCanVerify(to: canVerify)
  }
  
  func canVerifyDidChange(to canVerify: Bool) {
    output?.changeCanVerify(to: canVerify)
  }
  
  func verificationDidBegin() {
    output?.clearMessage()
    output?.changeIsVerifying(to: true)
  }
  
  func verificationDidEnd() {
    output?.changeIsVerifying(to: false)
    output?.leave()
  }
  
  func verificationDidFail(dueTo errors: [String]) {
    output?.changeIsVerifying(to: false)
    output?.showMessage(LoginMessage(errors: errors))
  }
  
  func showResendConfirmation() {
    let alert = ResendCodeConfirmaiton(message: "Are you sure you want a new verification code?",
                                       confirmActionText: "Confirm",
                                       cancelActionText: "Cancel")
    
    output?.showResendCodeConfirmaiton(alert)
  }
  
  func showIdentityCreation(withIdentity identity: RetailIdentity) {
    output?.changeIsVerifying(to: false)
    output?.goToIdentityCreationPage(withIdentity: identity)
  }
}
