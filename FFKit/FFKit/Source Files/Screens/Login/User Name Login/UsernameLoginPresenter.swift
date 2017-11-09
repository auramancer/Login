protocol UsernameLoginPresenterOutput: class {
  func setLogInEnabled(to: Bool)
  func showActivityMessage(_: String?)
  func hideActivityMessage()
  func showErrorMessage(_: String?)
  func hideErrorMessage()
  func close()
}

class UsernameLoginPresenter {
  weak var output: UsernameLoginPresenterOutput?
}

extension UsernameLoginPresenter: LoginInteractorOutput {
  func updateState(_ state: LoginState) {
    output?.setLogInEnabled(to: state == .ready)
    updateActivity(for: state)
  }
  
  private func updateActivity(for state: LoginState) {
    if state == .inProgress {
      output?.hideErrorMessage()
      output?.showActivityMessage(activityMessage)
    }
    else {
      output?.hideActivityMessage()
    }
  }
  
  private var activityMessage: String? {
    return nil // No text
  }
  
  func updateResult(_ result: LoginResult) {
    switch result {
    case let .failed(errors):
      let message = errorMessage(for: errors)
      output?.showErrorMessage(message)
    default:
      output?.close()
    }
  }
  
  private func errorMessage(for errors: [LoginError]) -> String {
    return "" // TBD
  }
}
