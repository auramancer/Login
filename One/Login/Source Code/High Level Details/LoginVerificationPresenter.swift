protocol LoginVerificationPresenterOutput: class {
  func enableVerify()
  func disableVerify()
  
  func showActivityMessage(_: String?)
  func hideActivityMessage()
  func showErrorMessage(_: String)
  func hideErrorMessage()
  
  func leave()
}

class LoginVerificationPresenter {
  weak var output: LoginVerificationPresenterOutput?
}

extension LoginVerificationPresenter: LoginVerificationInteractorOutput {
  func canVerifyDidChange(to canVerify: Bool) {
    if canVerify {
      output?.enableVerify()
    }
    else {
      output?.disableVerify()
    }
  }
  
  func verificationDidBegin() {
    output?.hideErrorMessage()
    output?.showActivityMessage(activityMessage)
  }
  
  private var activityMessage: String? {
    return nil // No text
  }
  
  func verificationDidEnd() {
    output?.hideActivityMessage()
    
    output?.leave()
  }
  
  func verificationDidFail(dueTo errors: [String]) {
    output?.hideActivityMessage()
    
    let message = errorMessage(for: errors)
    output?.showErrorMessage(message)
  }
  
  private func errorMessage(for errors: [String]) -> String {
    return errors.first ?? "Something went wrong."
  }
}
