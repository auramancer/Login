struct ResendCodeConfirmaitonAlert {
  let message: String?
  let confirmActionTitle: String?
}

protocol LoginVerificationPresenterOutput: class {
  func changeCanVerify(to: Bool)
  func changeIsVerifying(to: Bool)
  
  func showMessage(_: LoginMessage)
  func clearMessage()
  
  func showResendCodeConfirmaitonAlert(_: ResendCodeConfirmaitonAlert)
  func goToIdentityCreationPage(withIdentity: RetailIdentity)
  func leave()
}

class LoginVerificationPresenter {
  weak var output: LoginVerificationPresenterOutput?
}

extension LoginVerificationPresenter: LoginVerificationInteractorOutput {
  func didLoad(canVerify: Bool) {
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
    output?.showMessage(LoginMessage(text: errors.joined(separator: "\n\n"), style: .error))
  }
  
  func showResendConfirmation() {
    let alert = ResendCodeConfirmaitonAlert(message: "Are you sure you want a new verification code?",
                                            confirmActionTitle: "Confirm")
    
    output?.showResendCodeConfirmaitonAlert(alert)
  }
  
  func showIdentityCreation(withIdentity identity: RetailIdentity) {
    output?.goToIdentityCreationPage(withIdentity: identity)
  }
}
