typealias LoginDestination = String

protocol LoginPresenterOutput: class {
  func loginWasEnabled()
  func loginWasDisabled()
  func showActivityMessage(_: String?)
  func hideActivityMessage()
  func showErrorMessage(_: String?)
  func hideErrorMessage()
  
  func navigate(to: LoginDestination)
  func leave()
}

class LoginPresenter: LoginInteractorOutput {
  weak var output: LoginPresenterOutput?
  
  func loginWasEnabled() {
    output?.loginWasEnabled()
  }
  
  func loginWasDisabled() {
    output?.loginWasDisabled()
  }
  
  func loginDidBegin() {
    output?.hideErrorMessage()
    output?.showActivityMessage(activityMessage)
  }
  
  private var activityMessage: String? {
    return nil // No text
  }
  
  func loginDidEnd() {
    output?.hideActivityMessage()
    
    output?.leave()
  }
  
  func loginDidFail(dueTo errors: [LoginError]) {
    output?.hideActivityMessage()
    
    let message = errorMessage(for: errors)
    output?.showErrorMessage(message)
    
    output?.loginWasEnabled()
  }
  
  private func errorMessage(for errors: [LoginError]) -> String {
    return errors.first ?? "Something went wrong."
  }
  
  func showHelp(_ destination: LoginHelp) {
    output?.navigate(to: destination)
  }
}
